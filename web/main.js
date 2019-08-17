console.log("Anime4K");


function createShader(gl, type, source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);

    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        throw new Error(gl.getShaderInfoLog(shader));
    }

    return shader;
}

function createProgram(gl, vertexSource, fragmentSource) {
    var program = gl.createProgram();

    var vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexSource);
    var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentSource);

    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);

    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        throw new Error(gl.getProgramInfoLog(program));
    }

    var wrapper = {program: program};

    var numAttributes = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    for (var i = 0; i < numAttributes; i++) {
        var attribute = gl.getActiveAttrib(program, i);
        wrapper[attribute.name] = gl.getAttribLocation(program, attribute.name);
    }
    var numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
    for (var i$1 = 0; i$1 < numUniforms; i$1++) {
        var uniform = gl.getActiveUniform(program, i$1);
        wrapper[uniform.name] = gl.getUniformLocation(program, uniform.name);
    }

    return wrapper;
}

function createTexture(gl, filter, data, width, height) {
    var texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filter);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filter);
    if (data instanceof Uint8Array) {
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
    } else {
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, data);
    }
    gl.bindTexture(gl.TEXTURE_2D, null);
    return texture;
}

function bindTexture(gl, texture, unit) {
    gl.activeTexture(gl.TEXTURE0 + unit);
    gl.bindTexture(gl.TEXTURE_2D, texture);
}

function updateTexture(gl, texture, src) {
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, src);
}

function createBuffer(gl, data) {
    var buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
    return buffer;
}

function bindAttribute(gl, buffer, attribute, numComponents) {
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.enableVertexAttribArray(attribute);
    gl.vertexAttribPointer(attribute, numComponents, gl.FLOAT, false, 0, 0);
}

function bindFramebuffer(gl, framebuffer, texture) {
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    if (texture) {
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
    }
}


const quadVert = `
precision mediump float;

attribute vec2 a_pos;
varying vec2 v_tex_pos;

void main() {
    v_tex_pos = a_pos;
    gl_Position = vec4(1.0 - 2.0 * a_pos, 0, 1);
}
`;

const scaleFrag = `
precision mediump float;

uniform sampler2D u_texture;
uniform vec2 u_size;
varying vec2 v_tex_pos;

vec4 interp(const vec2 uv) {
    vec2 px = 1.0 / u_size;
    vec2 vc = (floor(uv * u_size)) * px;
    vec2 f = fract(uv * u_size);
    vec4 tl = texture2D(u_texture, vc);
    vec4 tr = texture2D(u_texture, vc + vec2(px.x, 0));
    vec4 bl = texture2D(u_texture, vc + vec2(0, px.y));
    vec4 br = texture2D(u_texture, vc + px);
    return mix(mix(tl, tr, f.x), mix(bl, br, f.x), f.y);
}

void main() {
    gl_FragColor = interp(1.0 - v_tex_pos);
    //gl_FragColor = texture2D(u_texture, 1.0 - v_tex_pos);
}
`;

const lumFrag = `
precision mediump float;

uniform sampler2D u_texture;
varying vec2 v_tex_pos;

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6.0;
}

void main() {
	vec4 rgb = texture2D(u_texture, 1.0 - v_tex_pos);
	float lum = getLum(rgb);
    gl_FragColor = vec4(lum);
}
`;

const pushFrag = `
precision mediump float;

uniform sampler2D u_texture;
uniform sampler2D u_textureTemp;
uniform float u_scale;
uniform float u_bold;
uniform vec2 u_pt;
varying vec2 v_tex_pos;

#define strength (min(u_scale / u_bold, 1.0))

vec4 HOOKED_tex(vec2 pos) {
    return texture2D(u_texture, pos);
}

vec4 POSTKERNEL_tex(vec2 pos) {
    return texture2D(u_textureTemp, pos);
}

vec4 getLargest(vec4 cc, vec4 lightestColor, vec4 a, vec4 b, vec4 c) {
	vec4 newColor = cc * (1.0 - strength) + ((a + b + c) / 3.0) * strength;
	if (newColor.a > lightestColor.a) {
		return newColor;
	}
	return lightestColor;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}

void main() {
    vec2 HOOKED_pos = v_tex_pos;

	vec2 d = u_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0.0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0.0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0.0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0.0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	vec4 lightestColor = cc;

	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, tl, t, tr);
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, t, tr);
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, tr);
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, b);
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, t, l, tl);
		}
    }
    
    gl_FragColor = lightestColor;
}
`;

const gradFrag = `
precision mediump float;

uniform sampler2D u_texture;
uniform sampler2D u_textureTemp;
uniform vec2 u_pt;
varying vec2 v_tex_pos;

vec4 HOOKED_tex(vec2 pos) {
    return texture2D(u_texture, 1.0 - pos);
}

vec4 POSTKERNEL_tex(vec2 pos) {
    return texture2D(u_textureTemp, 1.0 - pos);
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

void main() {
    vec2 HOOKED_pos = v_tex_pos;
    
	vec2 d = u_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0.0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0.0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0.0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0.0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-tl.a + tr.a - l.a - l.a + r.a + r.a - bl.a + br.a);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
    float ygrad = (-tl.a - t.a - t.a - tr.a + bl.a + b.a + b.a + br.a);
    
    gl_FragColor = vec4(1.0 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0.0, 1.0));
}
`;

const finalFrag = `
precision mediump float;

uniform sampler2D u_texture;
uniform sampler2D u_textureTemp;
uniform vec2 u_pt;
uniform float u_scale;
uniform float u_blur;
varying vec2 v_tex_pos;

#define strength (min(u_scale / u_blur, 1.0))

vec4 HOOKED_tex(vec2 pos) {
    return texture2D(u_texture, vec2(pos.x, 1.0 - pos.y));
}

vec4 POSTKERNEL_tex(vec2 pos) {
    return texture2D(u_textureTemp, vec2(pos.x, 1.0 - pos.y));
}

vec4 getAverage(vec4 cc, vec4 a, vec4 b, vec4 c) {
	return cc * (1.0 - strength) + ((a + b + c) / 3.0) * strength;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}

void main() {
    vec2 HOOKED_pos = v_tex_pos;
    
	vec2 d = u_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0.0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0.0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0.0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0.0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
        gl_FragColor = getAverage(cc, tl, t, tr);
        return;
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
            gl_FragColor = getAverage(cc, br, b, bl);
            return;
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
        gl_FragColor = getAverage(cc, r, t, tr);
        return;
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
            gl_FragColor = getAverage(cc, bl, l, b);
            return;
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
        gl_FragColor = getAverage(cc, r, br, tr);
        return;
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
            gl_FragColor = getAverage(cc, l, tl, bl);
            return;
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
        gl_FragColor = getAverage(cc, r, br, b);
        return;
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
            gl_FragColor = getAverage(cc, t, l, tl);
            return;
		}
	}
    
    gl_FragColor = cc;
}
`;

const drawFrag = `
precision mediump float;

uniform sampler2D u_texture;
uniform sampler2D u_textureOrig;
varying vec2 v_tex_pos;

void main() {
    vec4 color = texture2D(u_texture, 1.0 - v_tex_pos);
    vec4 colorOrig = texture2D(u_textureOrig, vec2(1.0 - v_tex_pos.x, v_tex_pos.y));
    gl_FragColor = vec4(color.rgb, colorOrig.a);
}
`;


function Scaler(gl) {
    this.gl = gl;

    this.inputTex = null;
    this.inputMov = null;
    this.inputWidth = 0;
    this.inputHeight = 0;

    this.quadBuffer = createBuffer(gl, new Float32Array([0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]));
    this.framebuffer = gl.createFramebuffer();
    
    this.scaleProgram = createProgram(gl, quadVert, scaleFrag);
    this.lumProgram = createProgram(gl, quadVert, lumFrag);
    this.pushProgram = createProgram(gl, quadVert, pushFrag);
    this.gradProgram = createProgram(gl, quadVert, gradFrag);
    this.finalProgram = createProgram(gl, quadVert, finalFrag);
    this.drawProgram = createProgram(gl, quadVert, drawFrag);
    
    this.tempTexture = null;
    this.tempTexture2 = null;
    this.tempTexture3 = null;

    this.bold = 6.0;
    this.blur = 2.0;
}

Scaler.prototype.inputImage = function(img) {
    const gl = this.gl;

    this.inputWidth = img.width;
    this.inputHeight = img.height;

    this.inputTex = createTexture(gl, gl.LINEAR, img);
    this.inputMov = null;
}

Scaler.prototype.inputVideo = function(mov) {
    const gl = this.gl;

    const width = mov.videoWidth;
    const height = mov.videoHeight;

    this.inputWidth = width;
    this.inputHeight = height;

    let emptyPixels = new Uint8Array(width * height * 4);
    this.inputTex = createTexture(gl, gl.LINEAR, emptyPixels, width, height);
    this.inputMov = mov;
}

Scaler.prototype.resize = function(scale) {
    const gl = this.gl;

    const width = Math.round(this.inputWidth * scale);
    const height = Math.round(this.inputHeight * scale);

    gl.canvas.width = width;
    gl.canvas.height = height;

    let emptyPixels = new Uint8Array(width * height * 4);
    this.scaleTexture = createTexture(gl, gl.LINEAR, emptyPixels, width, height);
    this.tempTexture = createTexture(gl, gl.LINEAR, emptyPixels, width, height);
    this.tempTexture2 = createTexture(gl, gl.LINEAR, emptyPixels, width, height);
    this.tempTexture3 = createTexture(gl, gl.LINEAR, emptyPixels, width, height);
}

Scaler.prototype.render = function() {
    if (!this.inputTex) {
        return;
    }


    const gl = this.gl;
    const scalePgm = this.scaleProgram;
    const lumPgm = this.lumProgram;
    const pushPgm = this.pushProgram;
    const gradPgm = this.gradProgram;
    const finalPgm = this.finalProgram;
    const drawPgm = this.drawProgram;


    if (this.inputMov) {
        updateTexture(gl, this.inputTex, this.inputMov);
    }


    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.STENCIL_TEST);

    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);


    // First upscaling with Bicubic interpolation.

    bindFramebuffer(gl, this.framebuffer, this.scaleTexture);

    gl.useProgram(scalePgm.program);

    bindAttribute(gl, this.quadBuffer, scalePgm.a_pos, 2);
    bindTexture(gl, this.inputTex, 0);
    gl.uniform1i(scalePgm.u_texture, 0);
    gl.uniform2f(scalePgm.u_size, this.inputWidth, this.inputHeight);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: scaleTexture


    bindFramebuffer(gl, this.framebuffer, this.tempTexture);

    gl.useProgram(lumPgm.program);

    bindAttribute(gl, this.quadBuffer, lumPgm.a_pos, 2);
    bindTexture(gl, this.scaleTexture, 0);
    gl.uniform1i(lumPgm.u_texture, 0);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: scaleTexture
    // PostKernel: tempTexture


    bindFramebuffer(gl, this.framebuffer, this.tempTexture2);

    gl.useProgram(pushPgm.program);

    bindAttribute(gl, this.quadBuffer, pushPgm.a_pos, 2);
    bindTexture(gl, this.scaleTexture, 0);
    bindTexture(gl, this.tempTexture, 1);
    gl.uniform1i(pushPgm.u_texture, 0);
    gl.uniform1i(pushPgm.u_textureTemp, 1);
    gl.uniform1f(pushPgm.u_scale, gl.canvas.width / this.inputWidth);
    gl.uniform2f(pushPgm.u_pt, 1.0 / gl.canvas.width, 1.0 / gl.canvas.height);
    gl.uniform1f(pushPgm.u_bold, this.bold);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: tempTexture2
    // PostKernel: tempTexture


    bindFramebuffer(gl, this.framebuffer, this.tempTexture);

    gl.useProgram(lumPgm.program);

    bindAttribute(gl, this.quadBuffer, lumPgm.a_pos, 2);
    bindTexture(gl, this.tempTexture2, 0);
    gl.uniform1i(lumPgm.u_texture, 0);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: tempTexture2
    // PostKernel: tempTexture


    bindFramebuffer(gl, this.framebuffer, this.tempTexture3);

    gl.useProgram(gradPgm.program);

    bindAttribute(gl, this.quadBuffer, gradPgm.a_pos, 2);
    bindTexture(gl, this.tempTexture2, 0);
    bindTexture(gl, this.tempTexture, 1);
    gl.uniform1i(gradPgm.u_texture, 0);
    gl.uniform1i(gradPgm.u_textureTemp, 1);
    gl.uniform2f(gradPgm.u_pt, 1.0 / gl.canvas.width, 1.0 / gl.canvas.height);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: tempTexture2
    // PostKernel: tempTexture3


    bindFramebuffer(gl, this.framebuffer, this.tempTexture);

    gl.useProgram(finalPgm.program);

    bindAttribute(gl, this.quadBuffer, finalPgm.a_pos, 2);
    bindTexture(gl, this.tempTexture2, 0);
    bindTexture(gl, this.tempTexture3, 1);
    gl.uniform1i(finalPgm.u_texture, 0);
    gl.uniform1i(finalPgm.u_textureTemp, 1);
    gl.uniform1f(finalPgm.u_scale, gl.canvas.width / this.inputWidth);
    gl.uniform2f(finalPgm.u_pt, 1.0 / gl.canvas.width, 1.0 / gl.canvas.height);
    gl.uniform1f(finalPgm.u_blur, this.blur);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    // Scaled: tempTexture
    // PostKernel: tempTexture3


    bindFramebuffer(gl, null);

    gl.useProgram(drawPgm.program);

    bindAttribute(gl, this.quadBuffer, drawPgm.a_pos, 2);
    bindTexture(gl, this.tempTexture, 0);
    bindTexture(gl, this.inputTex, 1);
    gl.uniform1i(drawPgm.u_texture, 0);
    gl.uniform1i(drawPgm.u_textureOrig, 1);

    gl.drawArrays(gl.TRIANGLES, 0, 6);
}


var scaler = null;

function onLoad() {
    const movOrig = document.getElementById('movOrig');
    const txtScale = document.getElementById('txtScale');
    const barBold = document.getElementById('sliderBold');
    const barBlur = document.getElementById('sliderBlur');

    const board = document.getElementById('board');
    const gl = board.getContext('webgl');


    movOrig.addEventListener('canplaythrough', function() {
        movOrig.play();
    }, true);
    movOrig.addEventListener('loadedmetadata', function() {
        let scale = parseFloat(txtScale.value);

        scaler = new Scaler(gl);
        scaler.inputVideo(movOrig);
        scaler.resize(scale);
    }, true);
    movOrig.addEventListener('error', function() {
        alert("Can't load the video.");
    }, true);


    const inputImg = new Image();
    inputImg.src = "input.png";
    inputImg.onload = function() {
        let scale = parseFloat(txtScale.value);

        scaler = new Scaler(gl);
        scaler.inputImage(inputImg);
        scaler.resize(scale);
    }


    function render() {
        if (scaler) {
            scaler.bold = parseFloat(barBold.value);
            scaler.blur = parseFloat(barBlur.value);
    
            scaler.render();
        }

        requestAnimationFrame(render);
    }
    
    requestAnimationFrame(render);
}

function getSourceType(uri) {
    const movTypes = ['mp4', 'webm', 'ogv', 'ogg'];

    let ext = uri.split('.').pop().split(/\#|\?/)[0];

    for (let i=0; i<movTypes.length; ++i) {
        if (ext === movTypes[i]) {
            return 'mov';
        }
    }

    return 'img';
}

function changeImage(src) {
    const movOrig = document.getElementById('movOrig');
    movOrig.pause();

    const txtScale = document.getElementById('txtScale');

    const inputImg = new Image();
    inputImg.crossOrigin = "Anonymous";
    inputImg.src = src;
    inputImg.onload = function() {
        let scale = parseFloat(txtScale.value);

        scaler.inputImage(inputImg);
        scaler.resize(scale);
    }
    inputImg.onerror = function() {
        alert("Can't load the image.");
    }
}

function changeVideo(src) {
    const movOrig = document.getElementById('movOrig');
    movOrig.src = src;
}

function onSourceChanged() {
    const txtSrc = document.getElementById('txtSrc');
    let uri = txtSrc.value;

    if (getSourceType(uri) == 'img') {
        changeImage(uri);
    }
    else {
        changeVideo(uri);
    }
}

function onSelectFile(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            let src = e.target.result;
            if (getSourceType(input.value) == 'img') {
                changeImage(src);
            }
            else {
                changeVideo(src);
            }
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function onScaleChanged() {
    const txtScale = document.getElementById('txtScale');

    scaler.resize(parseFloat(txtScale.value));
}