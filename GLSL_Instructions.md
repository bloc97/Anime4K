# Usage Instructions (GLSL / MPV) (v3.x)
*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

  1. Install [**mpv**](https://mpv.io/).  
  2. Download the .glsl shader files [**here**](https://github.com/bloc97/Anime4K/releases)  
  3. Copy the .glsl files to `%AppData%\mpv\shaders` for Windows or `~/.config/mpv/shaders` for Linux.  
  4. If `mpv.conf` does not exist in `%AppData%\mpv\` or `~/.config/mpv`, create an empty file and follow [**these instructions**](https://wiki.archlinux.org/index.php/Mpv#Configuration) to optimize your configuration.  
  5. For Anime4K v3.x, instead of activating a single shader, you should use a combination of shaders. Add one of the following lines to `mpv.conf` to enable the shaders:
  
**Note for Unix based OSes, ";" separators must be replaced with ":" as stated in the [mpv manual](https://mpv.io/manual/stable/#string-list-and-path-list-options).**
  
Here's a few shader combinations as a recommended starting point:
  
For 480/720p videos:
 - Remain as faithful to the original while enhancing details:  
 `glsl-shaders="~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`
 - Improve perceptual quality:  
 `glsl-shaders="~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`
 - Improve perceptual quality + deblur:  
 `glsl-shaders="~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`

For 1080p videos:
 - Remain as faithful to the original while enhancing details:  
 `glsl-shaders="~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`
 - Improve perceptual quality:  
 `glsl-shaders="~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`
 - Improve perceptual quality + deblur:  
 `glsl-shaders="~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"`
  
The file name might vary depending on the version, rename it accordingly. You can also replace the upscalers variant (M, L, UL) for better speed or quality. But please note that mpv does not allow the same shader to be activated twice, so if you want to use the same shader twice, you must make a copy of the file and rename one of them.  
Note: Due to some unknown cause (or intentional behaviour?) in mpv, using the exact same upscaling shaders variant twice or more causes the first pass to slow down significantly. Performance loss is especially noticeable at higher resolutions.

Alternatively add the following bindings to your `input.conf` to toggle the shader on or off at runtime using Ctrl+1, Ctrl+2, etc. 
Ctrl+0 will disable all the shaders. The order presented here is the same as above.
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 480/720p (Faithful)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 480/720p (Perceptual Quality)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Upscale_CNN_L_x2_Denoise.glsl;~~/shaders/Anime4K_Auto_Downscale_Pre_x4.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 480/720p (Perceptual Quality and Deblur)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 1080p (Faithful)"
CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 1080p (Perceptual Quality)"
CTRL+6 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Denoise_Bilateral_Mode.glsl;~~/shaders/Anime4K_Deblur_DoG.glsl;~~/shaders/Anime4K_DarkLines_HQ.glsl;~~/shaders/Anime4K_ThinLines_HQ.glsl;~~/shaders/Anime4K_Upscale_CNN_M_x2_Deblur.glsl"; show-text "Anime4k: 1080p (Perceptual Quality and Deblur)"
CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```
  
Note: If you wish to use the Upscale_Original and/or Deblur_Original shaders, make sure your mpv version is **v0.31** if you are using Windows and must use the D3D11 API, as there is a GLSL bug in v0.32, see https://github.com/bloc97/Anime4K/issues/66. Linux users are not affected. Windows users on the OpenGL or Vulkan API are not affected.
  
  6. To verify the installation was correctly done, use the MPV profiler to check if there are a few shaders with the name Anime4K running. To access the profiler, press Shift+I and then 2 on the keyboard's top row.  
This is what you should see (this example is from v2.0RC2, but also applies to newer versions):  
![Profiler](results/MPV_Profiler.png?raw=true)



