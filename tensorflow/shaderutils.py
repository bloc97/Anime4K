import numpy as np

#Format layer name preventing collisions
def format_layer_name(name):
    if type(name) is not str:
        name = name.name
    
    if "." in name:
        splitname = name.split(".")[-1]
        if "tf" in name or "tensorflow" in name:
            splitname = splitname + "_tf"
        return splitname
    else:
        return name + "_tf"

def simplify_model(model, simplify_threshold=4):
    for i, layer in enumerate(model.layers):
        flag_simplify(layer, simplify_threshold)
        #print(check_simplify(layer, simplify_threshold), layer.do_ignore)
    
def flag_simplify(layer, simplify_threshold):
    layer.do_simplify = False
    layer.do_ignore = False
    
    if any([name in layer.name for name in ["input", "ignore"]]):
        layer.do_ignore = True
        
    #Has many outputs (up until simplify_threshold) and is not output layer
    if len(layer._outbound_nodes) <= simplify_threshold and len(layer._outbound_nodes) > 0:
        #And is in the simplify nodes
        if any([name in layer.name for name in ["add", "concatenate", "crelu", "up_sampling2d"]]):
            layer.do_simplify = True
            layer.do_ignore = True
            return True
    return False
    
    
def get_simplified_tree(layer):
    layer_parent = layer._inbound_nodes[0].inbound_layers
    
    if type(layer_parent) is not list:
        layer_parent = [layer_parent]
    
    inputs = []
    for parent in layer_parent:
        if parent.do_simplify:
            inputs.append((parent.name, get_simplified_tree(parent)))
        else:
            inputs.append((parent.name, parent.output.shape[-1]))

    return inputs

def parse_inputs(node):
    
    newlist = []
    for name, new_node in node:
        
        if type(new_node) is not int:
            if "concatenate" in name:
                templist = []


                input_nodes = parse_inputs(new_node)
                #If it is a list
                if type(input_nodes) is list and len(input_nodes) > 0:
                    #If it is a 2D list
                    if type(input_nodes[0]) is list:
                        for u in input_nodes:
                            for v in u:
                                templist.append(v)
                    else:
                        for u in input_nodes:
                            templist.append(u)

                newlist.append(templist)

            elif "add" in name:
                templist = []
                input_nodes = parse_inputs(new_node)

                #If it is a list
                if type(input_nodes) is list and len(input_nodes) > 0:
                    #If it is a 2D list
                    if type(input_nodes[0]) is list:
                        for u in range(len(input_nodes[0])):
                            tl = []
                            for v in range(len(input_nodes)):
                                tl.append(input_nodes[v][u])
                            templist.append(("add", tl))
                    else:
                        for n in input_nodes:
                            templist.append(("add", n))
                            
                newlist.append(templist)

            elif "crelu" in name:
                templist = []
                input_nodes = parse_inputs(new_node)

                #If it is a list
                if type(input_nodes) is list and len(input_nodes) > 0:
                    #If it is a 2D list
                    if type(input_nodes[0]) is list:
                        for u in input_nodes:
                            for v in u:
                                templist.append(("pos_relu", v))
                            for v in u:
                                templist.append(("neg_relu", v))

                    else:
                        for u in input_nodes:
                            templist.append(("pos_relu", u))
                        for u in input_nodes:
                            templist.append(("neg_relu", u))
                else:
                    templist.append(("pos_relu", input_nodes))
                    templist.append(("neg_relu", input_nodes))
                    
                newlist.append(templist)
            elif "up_sampling2d" in name:
                newlist.append(parse_inputs(new_node))
                
            else:
                print("ERROR, LAYER NOT RECOGNIZED")
                    
        else:
            templist = []
            num_features = new_node
            formatted_name = format_layer_name(name)
            
            for i in range(0, num_features, 4):
                bind_i = i // 4
                bind_len = (min(num_features, i + 4)) - i
                templist.append(("direct", (formatted_name + (str(bind_i) if bind_i > 0 else ""), bind_len)))
            newlist.append(templist)
                
    if len(newlist) == 1:
        return newlist[0]
    
    return newlist
    
    
def get_unique_binds_recur(node, bind_set):
    if type(node) is list:
        for n in node:
            get_unique_binds_recur(n, bind_set)
    else:
        name, subnode = node
        if name == "direct":
            bind_set[subnode[0]] = subnode[1]
        else:
            get_unique_binds_recur(subnode, bind_set)
            
def get_unique_binds(node):
    bind_set = dict()
    get_unique_binds_recur(node, bind_set)
    return list(bind_set.keys())
            
def get_bind_num_features(node):
    if type(node) is list:
        features_sum = 0
        for n in node:
            features_sum += get_bind_num_features(n)
        return features_sum
    else:
        name, subnode = node
        if name == "direct":
            return subnode[1]
        elif name == "add":
            return get_bind_num_features(subnode[0])
        else:
            return get_bind_num_features(subnode)
        
def get_binds_split(node, max_bind_num=16):
    
    if type(node) is not list:
        node = [node]
        
    starti = 0
    splits = []
    for i in range(len(node)):
        current_node = node[starti:(i+1)]
        split_set = get_unique_binds(current_node)
        
        real_max_bind_num = max_bind_num if len(splits) == 0 else max_bind_num - 1 #Splitting needs to reserve one bind for the shader itself
        if (i + 1) == len(node):
            splits.append(current_node)
        elif len(split_set) > real_max_bind_num:
            splits.append(node[starti:i])
            starti = i
    
    return splits
    
    
def parse_expression_recur(node, with_offset=False):
    name, subnode = node
    
    if name == "add":
        return "(" + ("+".join([parse_expression_recur(n, with_offset) for n in subnode])) + ")"
            
    elif name == "pos_relu":
        return "(" + ("max(" + parse_expression_recur(subnode, with_offset) + ", 0.0)") + ")"
        
    elif name == "neg_relu":
        return "(" + ("max(-" + parse_expression_recur(subnode, with_offset) + ", 0.0)") + ")"
        
    elif name == "direct":
        if with_offset:
            return "(" + subnode[0] + "_texOff(vec2(x_off, y_off)))"
        else:
            return "(" + subnode[0] + "_tex(" + subnode[0] + "_pos))"
        
    else:
        print("ERROR UNKNOWN NODE")
        return parse_expression(subnode)
            
def parse_expression(node, feature_no, with_offset=False):
    if with_offset:
        return "#define go_" + str(feature_no) + "(x_off, y_off) " + parse_expression_recur(node, with_offset)
    else:
        return "#define g_" + str(feature_no) + " " + parse_expression_recur(node, with_offset)

def parse_conv2d(layer, hook="MAIN", desc=None, when=None, dtype=np.float32, max_bind_num=16):
    shader_string = ""
    
    #Get weights and biases if exists
    weights = np.transpose(np.array(layer.weights[0]), (1, 0, 2, 3)) #Correlation -> Convolution transpose
    bias = layer.weights[1] if len(layer.weights) > 1 else None
    
    #Parse shape
    kernel_height, kernel_width, input_size, output_size = weights.shape
    
    input_tree = get_simplified_tree(layer)
    input_features = parse_inputs(input_tree)
    
    #Get current layer name
    current_layer_name = format_layer_name(layer.name)
    
    if "lastresid" in layer.name: #Needs to bind to self, remove one from max bindings
        max_bind_num = max_bind_num - 1
    
    #For the total number of stages necessary
    for n in range(0, output_size, 4):
        
        #Split binds into multiple shaders if needed (when binding more than 16 textures)
        bind_split_list = get_binds_split(input_features, max_bind_num)
        
        #Get current shader's bind name
        n_i = n // 4
        current_bind_name = current_layer_name + (str(n_i) if n_i > 0 else "")
        
        current_start_feature = 0
        for bi, binds in enumerate(bind_split_list):
            
            bind_names = [bname for bname in get_unique_binds(binds)]
            
            
            #Create hook header
            if desc is None:
                desc = layer.name
            
            shader_string += "//!DESC " + desc + "-Conv-" + str(min(weights.shape[3], 4)) + "x" + str(weights.shape[0]) + "x" + str(weights.shape[1]) + "x" + str(weights.shape[2]) + "\n"
            shader_string += "//!HOOK " + hook + "\n"
            if "lastresid" in layer.name:
                shader_string += "//!BIND " + current_bind_name + "\n"
            
            for bind_name in bind_names:
                shader_string += "//!BIND " + bind_name + "\n"
            if bi > 0:
                shader_string += "//!BIND " + current_bind_name + "\n"
                
            shader_string += "//!SAVE " + current_bind_name + "\n"
            
            shader_string += "//!WIDTH " + bind_names[0] + ".w\n"
            shader_string += "//!HEIGHT " + bind_names[0] + ".h\n"
            
            if current_bind_name not in ["LUMA", "NATIVE", "RGB", "MAIN"] and "lastresid" not in layer.name:
                shader_string += "//!COMPONENTS 4\n"
            
            if when is not None:
                shader_string += "//!WHEN " + when + "\n"
                
            for bk, bind in enumerate(binds):
                if kernel_height == 1 and kernel_width == 1:
                    shader_string += parse_expression(bind, bk, False) + "\n"
                else:
                    shader_string += parse_expression(bind, bk, True) + "\n"
            
            
            #Create hook body
            shader_string += "vec4 hook() {\n"

            init_result = False

            
            #For the total number of binds necessary (input_channels / glsl_channels)
            for k, bind in enumerate(binds):
                current_feature_length = get_bind_num_features(bind)
                
                #For each spatial location within kernel
                for i, j in np.ndindex((kernel_height, kernel_width)):

                    #Compute offset
                    tex_off = (float(i - kernel_height // 2 + (1 - kernel_height % 2)), float(j - kernel_width // 2 + (1 - kernel_width % 2)))

                    #Gather current weights
                    current_weights = np.array(weights[i, j, current_start_feature:current_start_feature+current_feature_length, n:(n+4)], dtype=dtype)

                    #Pad until 4x4 matrix
                    current_weights = np.pad(current_weights, [[0, 4 - current_weights.shape[0]],[0, 4 - current_weights.shape[1]]])

                    #Flatten
                    current_weights = tuple(current_weights.flatten())

                    #Add tab and variables
                    shader_string += "    "
                    if init_result:
                        shader_string += "result += "
                    else:
                        shader_string += "vec4 result = "
                        init_result = True

                    #Add computation
                    #if tex_off == (0, 0):
                    #else:
                    if kernel_height == 1 and kernel_width == 1:
                        shader_string += "mat4" + str(current_weights) + " * g_" + str(k) + ";\n"
                    else:
                        shader_string += "mat4" + str(current_weights) + " * go_" + str(k) + str(tex_off) + ";\n"
                    
                current_start_feature += current_feature_length


            if bi > 0:
                shader_string += "    result += " + current_bind_name + "_tex(" + current_bind_name + "_pos);\n"
            
            if bias is not None and bi == (len(bind_split_list) - 1):
                #Gather current bias
                current_bias = np.array(bias[n:(n+4)], dtype=dtype)

                #Pad until vector of size 4
                current_bias = np.pad(current_bias, [[0, 4 - current_bias.shape[0]]])
                current_bias = tuple(current_bias)

                shader_string += "    result += vec4" + str(current_bias) + ";\n"
                
            if "lastresid" in layer.name:
                shader_string += "    return result + " + hook + "_tex(" + hook + "_pos);\n"
            else:
                shader_string += "    return result;\n"

            shader_string += "}\n"
        
            
    return shader_string



def parse_depth_to_space(layer, hook="MAIN", desc=None, when=None, max_bind_num=16):
    shader_string = ""
    
    #Parse shape
    input_size = layer.input.shape[-1]
    
    num_shaders = input_size//(4*4) + (input_size%(4*4) > 0)
    
    #Get previous layer name, assuming depth_to_space only has one input...
    previous_layer_name = format_layer_name(layer._inbound_nodes[0].inbound_layers)
    current_layer_name = format_layer_name(layer)
    
    #For the total number of stages necessary
    for n in range(num_shaders):
        
        #Get valid bind names
        bind_names = []
        for k in range(4):
            kn = n * 4 + k
            if (kn * 4) < input_size:
                bind_names.append(previous_layer_name + (str(kn) if kn > 0 else ""))
        
        while len(bind_names) < 4:
            bind_names.append(None)
        
        #Get bind name
        current_bind_name = current_layer_name + (str(n) if n > 0 else "")
        
        #Create hook header
        if desc is None:
            desc = layer.name

        shader_string += "//!DESC " + desc + "-Depth-to-Space\n"
        shader_string += "//!HOOK " + hook + "\n"
        
        if "lastresid" in layer.name:
            shader_string += "//!BIND " + current_bind_name + "\n"
            
        for bind_name in bind_names:
            if bind_name is not None:
                shader_string += "//!BIND " + bind_name + "\n"
        
        shader_string += "//!SAVE " + current_bind_name + "\n"
        
        if current_bind_name not in ["LUMA", "NATIVE", "RGB", "MAIN"] and "lastresid" not in layer.name:
            shader_string += "//!COMPONENTS 4\n"
            
        shader_string += "//!WIDTH " + bind_names[0] + ".w 2 *\n"
        shader_string += "//!HEIGHT " + bind_names[0] + ".h 2 *\n"
        if when is not None:
            shader_string += "//!WHEN " + when + "\n"

        #Create hook body
        shader_string += "vec4 hook() {\n"
        
        for bi, bind_name in enumerate(bind_names):
            
            if bind_name is not None:
                shader_string += "    vec2 f" + str(bi) + " = fract(" + bind_name + "_pos * " + bind_name + "_size);\n"
                shader_string += "    ivec2 i" + str(bi) + " = ivec2(f" + str(bi) + " * vec2(2.0));\n"
                shader_string += "    float c" + str(bi) + " = " + bind_name + "_tex((vec2(0.5) - f" + str(bi) + ") * " + bind_name + "_pt + " + bind_name + "_pos)[i" + str(bi) + ".y * 2 + i" + str(bi) + ".x];\n"
            else:
                if bi > 0:
                    shader_string += "    float c" + str(bi) + " = c" + str(bi-1) + ";\n"
                else:
                    shader_string += "    float c" + str(bi) + " = 0.0;\n"
            
        
        if "lastresid" in layer.name:
            shader_string += "    return vec4(c0, c1, c2, c3) + " + hook + "_tex(" + hook + "_pos);\n"
        else:
            shader_string += "    return vec4(c0, c1, c2, c3);\n"
        
        
        shader_string += "}\n"
        
        
            
    return shader_string
    
    
def parse_add(layer, hook="MAIN", desc=None, when=None, max_bind_num=16):
    shader_string = ""
    
    #Parse shape
    input_size = layer.output.shape[-1]
    
    num_shaders = input_size//4 + (input_size%4 > 0)
    
    #Get previous layer names
    previous_layer_names = [format_layer_name(l) for l in layer._inbound_nodes[0].inbound_layers]
    current_layer_name = format_layer_name(layer)
    
    #For the total number of stages necessary (output_channels / glsl_channels)
    #First half of CReLU
    for n in range(num_shaders):
        
        #Get bind name
        bind_names = [previous_layer_name + (str(n) if n > 0 else "") for previous_layer_name in previous_layer_names]
        current_bind_name = current_layer_name + (str(n) if n > 0 else "")
        
        #Create hook header
        if desc is None:
            desc = layer.name

        shader_string += "//!DESC " + desc + "-Add\n"
        shader_string += "//!HOOK " + hook + "\n"
        for bind_name in bind_names:
            shader_string += "//!BIND " + bind_name + "\n"
        shader_string += "//!SAVE " + current_bind_name + "\n"
        if current_bind_name not in ["LUMA", "NATIVE", "RGB", "MAIN"]:
            shader_string += "//!COMPONENTS 4\n"
        shader_string += "//!WIDTH " + bind_names[0] + ".w\n"
        shader_string += "//!HEIGHT " + bind_names[0] + ".h\n"
        if when is not None:
            shader_string += "//!WHEN " + when + "\n"

        #Create hook body
        bind_str = [layer_name + "_tex(" + layer_name + "_pos)" for layer_name in bind_names]
        
        shader_string += "vec4 hook() {\n"
        shader_string += "    return "
        shader_string += " + ".join(bind_str)
        shader_string += ";\n"
        shader_string += "}\n"
        
        
            
    return shader_string

def gen_shader(model, file, hook="MAIN", desc=None, when=None):
    simplify_model(model)
    shader_str = ""
    for layer in model.layers:
        if layer.do_ignore:
            continue

        if "conv2d" in layer.name:
            shader_str += parse_conv2d(layer, hook=hook, desc=desc, when=when)
        elif "add" in layer.name:
            shader_str += parse_add(layer, hook=hook, desc=desc, when=when)
        elif "depth_to_space" in layer.name:
            shader_str += parse_depth_to_space(layer, hook=hook, desc=desc, when=when)
        elif "input" in layer.name:
            print("Skipping input layer:", layer.name)
        else:
            print("UNKNOWN", layer.name)

    with open(file, "w") as text_file:
        text_file.write(shader_str)