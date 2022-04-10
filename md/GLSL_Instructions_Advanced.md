# Advanced Usage Instructions (GLSL / MPV) (v4.x)
## Modes
Now, Anime4K has 3 major modes, as the small CNN networks cannot learn effectively every type of distribution shift and degradation seen in the wild. Human judgement will serve (for now) as the stopgap solution. Usually the correct mode is the one that looks best.

The easiest way is to first visually inspect each mode in the A-B-C order. Mode A has the most visible artifacts of the three modes if used incorrectly. B and C can be harder to distinguish for lower resolution anime. 

If you want increased perceptual quality, use the corresponding secondary mode. 
| Primary Mode         | Corresponding Secondary Mode |
| ------------- |-------------|
| A | A+A |
| B | B+B |
| C | C+A |

Here's what each mode is optimized for and what it does:

| Modes         | Optimized for?           | Positive effects  | Negative effects (If used incorrectly) |
| ------------- |-------------| -----| -----|
| A   | Most 1080p anime<br/>Some older 720p anime<br/>Most old SD anime<br/>\(High amounts of blur)<br/>\(A lot of resampling artifacts)<br/>\(Smearing due to compression) | High perceptual quality<br/>Reduces compression artifacts<br/>Reconstructs most degraded lines<br/>Reduces large amounts of blur<br/>Reduces noise | Can amplify ringing if already present<br/>Can amplify banding if already present<br/>Strong denoising might blur textures |
| B   | Some 1080p anime<br/>Most 720p anime<br/>1080p->720p downscaled anime<br/>\(Low amounts of blur)<br/>\(Some resampling artifacts)<br/>\(Ringing due to downsampling) | Reduces compression artifacts<br/>Reconstructs some degraded lines<br/>Reduces some blur<br/>Reduces noise<br/>Reduces ringing<br/>Reduces aliasing | Some artifacts might not be removed<br/>Some lines might still be blurry<br/>Strong denoising might blur textures|
| C   | 1080p->480p downscaled anime<br/>Very rarely, 1080p animated movies<br/>Images with no degradation<br/>Wallpapers<br/>Pixiv art      | Highest PSNR<br/>Reduces noise | Low perceptual quality<br/>Can amplify ringing if already present<br/>Can amplify resampling artifacts|
| A+A\* | Same as A      | Highest perceptual quality<br/>Reconstructs almost all degraded lines<br/>Same positive effects from mode A | Can cause severe ringing<br/>Can cause banding<br/>Can cause aliasing<br/>Same negative effects from mode A<br/>Slower than mode A|
| B+B\* | Same as B      | High perceptual quality<br/>Same positive effects from mode B | Same negative effects from mode B<br/>Slower than mode B|
| C+A\* | Same as C      | Slightly higher perceptual quality<br/>Same positive effects from mode C | Same negative effects from mode C<br/>Slower than mode C|


\*These modes should only be used on upscaling ratios of x2 or higher. If you have a 1080p screen, using mode A on 1080p anime will improve image quality, but mode A+A will most likely oversharpen and degrade the image.

## Advanced Customization
Not satisfied from simply using the default options? Curious about unsupported/weird modes such as B+A, A+B or B+A+A ? This quick guide will get you started on customizing your own restoration pipeline.

First, the basics. 

  -  All the shaders can be used standalone or in combination with any other shaders.
  -  You can only use each shader file once. Using the same file two or more times causes buggy behaviour and loss of performance. Either use a different variant or copy and rename the duplicate shaders.
  -  The shaders process the image in the same order as the filename order given in `input.conf`. One exception is `Clamp_Highlights`, explained in the table below.
  -  You are free to choose the CNN variant (S, M, L, VL, UL) for better speed or quality. Each step in size for CNN shaders doubles the processing time. For example, if the M version takes 5ms to run, the L version should take approximately 10ms to run, 20ms for VL and so on.
  -  Non-CNN shaders are significantly faster but might be of lower quality.

Quick explanation of each shader type:

| Shader Type (in order of importance) | Effect |
| ------------- |-------------|
| Restore | The shader that makes Anime4K different from other upscalers. Restores image, best used before upscaling. Removes compression artifacts, blur, ringing, etc. `Restore` is more optimized for upsampling artifacts and blur, while `Restore_Soft` is more optimized for downsampling artifacts and aliasing. |
| Upscale | Upscales an image by a factor of x2, assumes image contains no degradation. |
| Upscale_Denoise | Upscales an image by a factor of x2 and denoises it with no GPU performance penality. |
| Clamp_Highlights | Computes and saves image statistics at the location it is placed in the shader stage, then clamps the image highlights at the end after all the shaders to prevent overshoot and reduce ringing. |
| Darken | Darkens lines in image. As what constitutes a line is ambiguous, might darken other stuff. Use according to personal taste. |
| Thin | Makes lines thinner in image. As what constitutes a line is ambiguous, might thin other stuff. Use according to personal taste. |
| Denoise | Applies a denoising filter to the image. |
| Deblur | Applies a deblur filter to the image. Sharpens details without overshoot or ringing. |
| AutoDownscalePre_x4 | Downscales an image after a first upscaling step, so that the second x2 upscaling step exactly matches screen size. This improves performance without noticeably impacting quality as you will not be working with images larger than the screen size. Should be placed between two Upscale shaders. Without this shader, the default behaviour is to downscale to the screen size after running all shaders. |
| AutoDownscalePre_x2 | Downscales an image after a first upscaling step to match screen size. This improves performance without noticeably impacting quality as you will not be working with images larger than the screen size. Should be placed after the first Upscale shader. Without this shader, the default behaviour is to downscale to the screen size after running all shaders. |
____
Overview of default modes:
| Mode         | Shaders |
| ------------- |-------------|
| A | `Restore -> Upscale -> Upscale` |
| B | `Restore_Soft -> Upscale -> Upscale` |
| C | `Upscale_Denoise -> Upscale` |
| A+A | `Restore -> Upscale -> Restore -> Upscale` |
| B+B | `Restore_Soft -> Upscale -> Restore_Soft -> Upscale` |
| C+A | `Upscale_Denoise -> Restore -> Upscale` |

*Note: Clamp_Highlights and AutoDownscalePre were removed from table for clarity.*
____
How the modes are defined:

  -  Mode A is defined initially as: `Restore -> Upscale`
  -  Mode B is defined initially as: `Restore_Soft -> Upscale`
  -  Mode C is defined initially as: `Upscale`
  -  If the mode does not start with a `Restore` shader, it must start with a `Upscale_Denoise` or `Denoise` shader, as almost every video compression algorithm is lossy.
  -  All modes have to add upscale shaders until the entire shader pipeline upscales at least 4x. A reasonable assumption is the smallest reasonable video size being 480p and the largest screen being 4K, upscaling at 4x is close to the 4.5x of 480p->4K.
____
With the definitions above, we can see for example, what C+A+B is.

  1. Initial definition:<br/>`C (Upscale) -> A (Restore -> Upscale) -> B (Restore_Soft -> Upscale)`
  2. All modes have to start with restore/denoise:<br/>`C (Upscale_Denoise) -> A (Restore -> Upscale) -> B (Restore_Soft -> Upscale)`
  3. Upscale ratio of 4x is already met.
  4. C+A+B is:<br/>`Upscale_Denoise -> Restore -> Upscale -> Restore_Soft -> Upscale`
  5. Shader variants (S/M/L/VL/UL) can be chosen at will.

## Best Practices

It is recommended to always include `Clamp_Highlights` at the beginning to prevent ringing in some anime, but removing it will slightly improve speed.

Adding a `Restore` shader after an upscaling step improves perceptual quality, but makes processing slower and might introduce artifacts.

Shaders applied after a x2 upscaling step will take four times the processing time. For example, if a shader takes 10ms to run when placed before a upscaler, it will need 40ms if placed after the upscaler. This can be counteracted by using a smaller CNN variant two steps below. (eg. S instead of L)

Artifacts introduced by lower quality shaders (eg. M or S variants) usually are not noticeable when working at very high resolutions. This advantage can be used to reduce GPU fan noise/heat and power use if you do not mind slightly lower image quality.

The target for 24fps video is usually ~41ms. Frame drops will appear if the GPU cannot keep up. If that happens, use lower quality/faster shader variants.
Use the mpv profiler (press Shift+I and then 2 on the keyboard's top row) to verify whether your GPU can keep up.

| Video Framerate | Maximum time (ms) |
|-----------|-------------------|
| 24        | 41                |
| 30        | 33                |
| 60        | 16                |


----

