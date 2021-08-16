from PIL import Image
import IPython
from io import BytesIO
import numpy as np
import math
import os
import tensorflow as tf


#Takes as input an image/array of size [height, width, channels] with range of 0-255
def show_image(img, width=None, height=None, fmt='png'):
    if width is None:
        width = img.shape[-2]
    if height is None:
        height = img.shape[-3]
    f = BytesIO()
    Image.fromarray(np.clip(np.array(img), 0, 255).astype(np.uint8)).save(f, fmt)
    IPython.display.display(IPython.display.Image(data=f.getvalue(), width=width, height=height))

#Takes as input images of size [batch, height, width, channels] with range of 0-255
def show_images(images, show_max=5, scale=1, val_range=[0, 255]):
    
    #Convert to numpy array, force eager execution when using tensorflow
    images = np.array(images)
    #Normalize images
    images = np.clip(((images - val_range[0]) / (val_range[1] - val_range[0])) * 255, 0, 255).astype(np.uint8)
    
    #Adding channel missing axis automatically
    if images.shape[-1] != 3 and images.shape[-1] != 1:
        if len(images.shape) > 3:
            return
        images = images[...,np.newaxis]
    
    #Adding batch missing axis automatically
    if len(images.shape) == 3:
        images = images[np.newaxis,...]
    
    #Compute max numbers of images to show
    show_max = min(show_max, len(images))
    
    #Concatenate images in x-axis (horizontally)
    images = np.concatenate(images[:show_max], axis=-2)
    
    #Remove extra axis if necessary
    if images.shape[-1] == 1:
        images = images[..., 0]
    
    show_image(images, images.shape[1]*scale, images.shape[0]*scale)

def check_is_image(obj):
    if tf.is_tensor(obj):
        tshape = tf.shape(obj)
        if len(tshape) == 3:
            if tshape[-1] == 1 or tshape[-1] == 3:
                return True
    return False

def check_is_batch(obj):
    if tf.is_tensor(obj):
        tshape = tf.shape(obj)
        if len(tshape) == 4:
            if tshape[-1] == 1 or tshape[-1] == 3:
                return True
    return False

def recursive_max_horizontal_size(tree):
    if check_is_batch(tree) or check_is_image(tree):
        return tf.shape(tree)[-3]
    else:
        max_val = 0
        for ex in tree:
            max_val = max(recursive_max_horizontal_size(ex), max_val)
        return max_val

def preview_dataset(dataset, show_max=5, scale=1, normalize_scale=True, val_range=[0, 255]):
    dataset_example = list(dataset.prefetch(tf.data.AUTOTUNE).take(show_max)) #Take from dataset, might be slow and unoptimized if dataset is not created from generator...
    
    target_size = recursive_max_horizontal_size(dataset_example) if normalize_scale else None
    return preview_dataset_list(dataset_example, min(show_max, len(dataset_example)), scale, float(target_size), val_range)

    
def preview_dataset_list(dataset_list, show_max, scale, target_size, val_range):
    #Take a single example out of dataset
    dataset_example = dataset_list[0]
    
    #Dataset gives out a tensor
    if tf.is_tensor(dataset_example):
        
        #Compute scaled size if asked
        tshape = tf.shape(dataset_example)
        if target_size is not None and len(tshape) >= 3:
            scale = target_size / float(tshape[-3]) * scale
            
        #If it is a batch
        if check_is_batch(dataset_example):
            #Show the batch directly
            show_images(dataset_example, show_max, scale, val_range)
        #If not a batch
        elif check_is_image(dataset_example):
            #Show list
            show_images(dataset_list, show_max, scale, val_range)
        
    #Dataset does not give out a tensor
    else:
        #Call function recursively with inner pairs
        for k in range(len(dataset_example)):
            sublist = [dataset_list[i][k] for i in range(len(dataset_list))]
            preview_dataset_list(sublist, show_max, scale, target_size, val_range)
            

    
def get_gaussian_kernel(shape=(7, 7), sigma=1.0):
    m, n = [(sh - 1.0) / 2.0 for sh in shape]
    x = tf.expand_dims(tf.range(-n, n + 1,dtype=tf.float32), 1)
    y = tf.expand_dims(tf.range(-m, m + 1,dtype=tf.float32), 0)
    
    h = tf.exp(tf.math.divide_no_nan(-((x*x) + (y*y)), 2 * sigma * sigma))
    h = tf.math.divide_no_nan(h,tf.reduce_sum(h))
    return h

def get_lanczos_kernel(shape=(7, 7), sigma=1.0):
    m, n = [(sh - 1.0) / 2.0 for sh in shape]
    x = tf.expand_dims(tf.range(-n, n + 1,dtype=tf.float32), 1)
    y = tf.expand_dims(tf.range(-m, m + 1,dtype=tf.float32), 0)
    
    d = tf.math.sqrt((x * x) + (y * y))
    h = tf.experimental.numpy.sinc(d) * tf.experimental.numpy.sinc(d / sigma)
    h = tf.math.divide_no_nan(h, tf.reduce_sum(h))
    return h

def gaussian_blur_no_pad(inp, shape=(7, 7), sigma=1.0):
    
    #Add axis if rank is 3 instead of 4
    imgshape = tf.shape(inp)
    if len(imgshape) == 3:
        inp = inp[tf.newaxis,...]
    
    in_channel = tf.shape(inp)[-1]
    k = get_gaussian_kernel(shape, sigma)
    k = tf.expand_dims(k, axis=-1)
    k = tf.repeat(k, in_channel, axis=-1)
    k = tf.reshape(k, (*shape, in_channel, 1))
    conv = tf.nn.depthwise_conv2d(inp, k, strides=[1,1,1,1], padding="VALID")
    
    #Remove axis if added beforehand
    if len(imgshape) == 3:
        conv = conv[0]
    
    return conv

def lanczos_ring_no_pad(inp, shape=(7, 7), sigma=1.0):
    
    #Add axis if rank is 3 instead of 4
    imgshape = tf.shape(inp)
    if len(imgshape) == 3:
        inp = inp[tf.newaxis,...]
        
    in_channel = tf.shape(inp)[-1]
    k = get_lanczos_kernel(shape, sigma)
    k = tf.expand_dims(k, axis=-1)
    k = tf.repeat(k, in_channel, axis=-1)
    k = tf.reshape(k, (*shape, in_channel, 1))
    conv = tf.nn.depthwise_conv2d(inp, k, strides=[1,1,1,1], padding="VALID")
    
    #Remove axis if added beforehand
    if len(imgshape) == 3:
        conv = conv[0]
    
    return conv

#Shape should be odd integer to prevent padding errors
def degrade_ring(img, sigma, shape=(7, 7), do_clip=True):
    
    #Padding to preserve size of the input, pad with reflect to prevent image mean shift
    img = tf.pad(img, [[shape[0]//2, shape[0]//2], [shape[1]//2, shape[1]//2], [0, 0]], mode="REFLECT")
    img = lanczos_ring_no_pad(img, shape, sigma)
    
    if do_clip:
        img = tf.clip_by_value(img, 0, 1)
        
    return img

#Shape should be odd integer to prevent padding errors
def degrade_blur_gaussian(img, sigma, shape=(7, 7), do_clip=True):
    
    #Padding to preserve size of the input, pad with reflect to prevent image mean shift
    img = tf.pad(img, [[shape[0]//2, shape[0]//2], [shape[1]//2, shape[1]//2], [0, 0]], mode="REFLECT")
    img = gaussian_blur_no_pad(img, shape, sigma)
    
    if do_clip:
        img = tf.clip_by_value(img, 0, 1)
        
    return img
    
def degrade_noise_gaussian(img, sigma, color=True, low_freq_sigma=None, low_freq_shape=(7, 7), do_clip=True):
    
    imgshape = tf.shape(img)
    if color:
        rg = tf.random.normal(imgshape, mean=0, stddev=rs)
    else:
        rg = tf.random.normal(imgshape[:-1], mean=0, stddev=rs)[..., tf.newaxis]
        
    #Low frequency blur if requested
    if low_freq_sigma is not None:
        rg = degrade_blur_gaussian(rg, low_freq_sigma, low_freq_shape, do_clip=False)
    
    img = img + rg
    
    if do_clip:
        img = tf.clip_by_value(img, 0, 1)
    
    return img

def degrade_rgb_to_yuv(img, jpeg_factor=None, chroma_subsampling=True, chroma_method="area", do_clip=True):
    img_yuv = tf.image.rgb_to_yuv(img)
    img_y, img_u, img_v = tf.split(img_yuv, 3, axis=-1)
    
    imgshape = tf.shape(img)
    yuvshape = tf.shape(img_yuv)
    
    if chroma_subsampling:
        img_u = tf.image.resize(img_u, [yuvshape[-3]//2, yuvshape[-2]//2], method=chroma_method)
        img_v = tf.image.resize(img_v, [yuvshape[-3]//2, yuvshape[-2]//2], method=chroma_method)
        
    if jpeg_factor is not None:
        img_y = tf.image.adjust_jpeg_quality(img_y, jpeg_factor)
        
    img_u = img_u + 0.5
    img_v = img_v + 0.5

    if jpeg_factor is not None:
        img_u = tf.image.adjust_jpeg_quality(img_u, jpeg_factor)
        img_v = tf.image.adjust_jpeg_quality(img_v, jpeg_factor)
    
    if do_clip:
        img_y = tf.clip_by_value(img_y, 0, 1)
        img_u = tf.clip_by_value(img_u, 0, 1)
        img_v = tf.clip_by_value(img_v, 0, 1)
    
    return (img_y, img_u, img_v)
    
def degrade_yuv_to_rgb(img, chroma_method="bicubic", do_clip=True):
    img_y, img_u, img_v = img
    img_uv = tf.concat([img_u, img_v], axis=-1)
    
    yshape = tf.shape(img_y)
    uvshape = tf.shape(img_uv)
    
    if yshape[-3] != uvshape[-3] or yshape[-2] != uvshape[-2]:
        img_uv = tf.image.resize(img_uv, [yshape[-3], yshape[-2]], method=chroma_method)
        
    img_uv = img_uv - 0.5
    img_yuv = tf.concat([img_y, img_uv], axis=-1)
    
    img = tf.image.yuv_to_rgb(img_yuv)
    
    if do_clip:
        img = tf.clip_by_value(img, 0, 1)
        
    return img