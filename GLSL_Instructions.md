# Usage Instructions (GLSL / MPV) (v4.x)
*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

  1. Install [**mpv**](https://mpv.io/).  
  2. Download the .glsl shader files [**here**](https://github.com/bloc97/Anime4K/releases)  
  3. Copy the .glsl files to `%AppData%\mpv\shaders` for Windows or `~/.config/mpv/shaders` for Linux.  
  4. If `mpv.conf` does not exist in `%AppData%\mpv\` or `~/.config/mpv`, create an empty file and follow [**these instructions**](https://wiki.archlinux.org/index.php/Mpv#Configuration) to optimize your configuration.  
  5. For Anime4K v4.x, instead of activating a single shader, you should use a combination of shaders. Add one of the following lines to `mpv.conf` to enable the shaders:
  
**Note for Unix based OSes, ";" separators must be replaced with ":" as stated in the [mpv manual](https://mpv.io/manual/stable/#string-list-and-path-list-options).**

Default fast shaders for 1080p->4K upscaling:  
```
glsl-shaders="~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"
```
----
Here's a few shader combinations as a recommended starting point:

For 1080p anime:
 - `Clamp_Highlights -> Restore_CNN_Moderate -> Upscale_CNN`

For 1080p anime that has been downscaled to 720p:
 - `Clamp_Highlights -> Restore_CNN_Light -> Upscale_CNN -> AutoDownscalePre_x4 -> Upscale_CNN`

For 1080p anime that has been downscaled to 540p/480p:
 - `Clamp_Highlights -> Upscale_Denoise_CNN -> Restore_CNN_Moderate -> Upscale_CNN`

For older standard definition (720p/560p/480p) anime:
 - `Clamp_Highlights -> Restore_CNN_Moderate -> Upscale_CNN -> Upscale_CNN`

----
It is recommended to always include `Clamp_Highlights` to prevent ringing in some anime, but removing it will slightly improve speed.

Adding a restore shader after each upscaling step significantly improves perceptual quality, but makes processing slower and might introduce artifacts.
For example:
 - `Clamp_Highlights -> Restore_CNN_Moderate -> Upscale_CNN -> Restore_CNN_Moderate -> Upscale_CNN -> Restore_CNN_Moderate`

You are free to choose the CNN variant (S, M, L, VL, UL) for better speed or quality. But please note that activating the same shader variant two times or more causes performance problems when upscaling, it is recommended to add each shader only once.
Each step in size for CNN shaders doubles the processing time. For example, if the M version takes 5ms to run, the L version should take approximately 10ms to run, 20ms for VL and so on.

Shaders applied after a x2 upscaling step will take four times the processing time. For example, if a shader takes 10ms to run when placed before a upscaler, it will need 40ms if placed after the upscaler. This can be counteracted by using a smaller CNN variant two steps below. (eg. S instead of L)

Artifacts introduced by lower quality shaders (eg. M or S variants) usually are not noticeable when working at very high resolutions. This advantage can be used to reduce GPU fan noise/heat and power use if you do not mind slightly lower image quality.

The target for 24fps video is usually ~41ms. Frame drops will appear if the GPU cannot keep up. If that happens, use lower quality/faster shader variants.

| Video Framerate | Maximum time (ms) |
|-----------|-------------------|
| 24        | 41                |
| 30        | 33                |
| 60        | 16                |


----

Alternatively add the following bindings to your `input.conf` to toggle the shader on or off at runtime using Ctrl+1, Ctrl+2, etc. 
Ctrl+0 will disable all the shaders. The order presented here is the same as above.

For 4K screens with less powerful GPUs:
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Modern 1080p->4K (Fast)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Modern 720p->4K (Fast)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Modern SD->4K (Fast)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Old SD->4K (Fast)"

CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern 1080p->4K +Perceptual (Fast)"
CTRL+6 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern 720p->4K +Perceptual (Fast)"
CTRL+7 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern SD->4K +Perceptual (Fast)"
CTRL+8 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Old SD->4K +Perceptual (Fast)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```

For 4K screens with better GPUs:
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl"; show-text "Anime4K: Modern 1080p->4K (HQ)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Modern 720p->4K (HQ)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Modern SD->4K (HQ)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Old SD->4K (HQ)"

CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern 1080p->4K +Perceptual (HQ)"
CTRL+6 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern 720p->4K +Perceptual (HQ)"
CTRL+7 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Modern SD->4K +Perceptual (HQ)"
CTRL+8 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_S.glsl"; show-text "Anime4K: Old SD->4K +Perceptual (HQ)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```

For 1080p screens with less powerful GPUs:
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Modern 1080p (Fast)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Modern 720p->1080p (Fast)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Modern SD->1080p (Fast)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Old SD->1080p (Fast)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```

For 1080p screens with better GPUs:
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_VL.glsl"; show-text "Anime4K: Modern 1080p (HQ)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl"; show-text "Anime4K: Modern 720p->1080p (HQ)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Modern SD->1080p (HQ)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Light_VL.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_L.glsl;~~/shaders/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Old SD->1080p (HQ)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```

----
  6. To verify the installation was correctly done, use the MPV profiler to check if there are a few shaders with the name Anime4K running. To access the profiler, press Shift+I and then 2 on the keyboard's top row.  
This is what you should see (this example is from v2.0RC2, but also applies to newer versions):  
![Profiler](results/MPV_Profiler.png?raw=true)



