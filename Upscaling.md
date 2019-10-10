### Note for those who think this is not a 'upscaling' algorithm.

The word you are actually looking for is "interpolation".

No, this algorithm doesn't do any rigorous interpolation. The interpolation step can be done by Nearest-Neighbor, Bilinear, Bicubic or any of your algorithm of choice. It just happens that the better the interpolation algorithm, the better the final results.

However, it seems that when an upscaling algorithm is very complex (xBR or waifu2x), people tend to not care about the definitions and agree that it is somehow "super-resolution" and not a "sharpening" filter. But when the algorithm is extremely simple, like Anime4K in this case, they immediately assume it is a "sharpening" algorithm.  

Somehow "sharpening" is bad but "super-resolution" is good when they are referring to the same thing?

It is important to understand that De-Blurring/Sharpening (in the specific case of gaussian blur) and Super-Resolution are **equivalent** in signal processing. If your algorithm can do one, it can do the other!

A Super-Resolution algorithm can be used to deblur, by first determining the blur factor, downscaling the image accordingly, and applying the SR algorithm.  
A deblur algorithm can be used to super-resolve, by first upsampling an low resolution image, applying gaussian blur, and applying the deblur algorithm. (This is what Anime4K does!)

Over-sharpening is usually what people associate with "sharpening" algorithms. But, it is not because they are "sharpening" algorithms that they are somehow "bad", it is simply because they are too simple or used for the wrong purpose. In Anime4K's case, we're sacrificing smoothness by introducing some aliasing, but with the benefit of **zero** ringing artifacts. Ringing is much more noticeable compared to aliasing when watching anime on 4K screens.

Just as how unsharp masking can ruin an image with ringing, Anime4K can do the same with aliasing if not used properly. People who don't mind ringing can keep using unsharp masking while those who don't mind aliasing can use Anime4K.

For those commenting around about sharpening = bad, please, do some research before spreading misinformation.
