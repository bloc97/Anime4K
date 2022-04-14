# Usage Instructions (GLSL / MPV) (v4.x)

## Installing and setting up Anime4K for Linux-based Distributions (and other Unix-like OS)

  1. Install `mpv` from repositories of your distribution, some of the common ones are mentioned here
      ### Fedora Silverblue
        1. Install the RPM-Fusion repository, if not installed already, paste the below command in the terminal

            `sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm`

        2. Reboot and install `mpv`
        
        3. Reboot and continue to step 2
       
        ### Fedora Workstation/Spins
        1. Install the RPM-Fusion repository, if not installed already, paste the below command in the terminal  
       
           `sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm`
         
         sudo dnf install mpv
         
   - Note: RPM Fusion command for both Fedora Workstation and Fedora Silverblue will add both "free" and "non-free" repository.  
         To know more about these you can check this [link](https://rpmfusion.org/Configuration)
         
        ### Debian/Ubuntu and Derivatives
         sudo apt install mpv
         
   - Note: Debian and Ubuntu usually ships with the older version of mpv player in their official repositories. It is advised to check flatpak guide below as it stays upto date with the upstream. 

        ### Arch and Derivatives
         sudo pacman -S mpv

        ### Gentoo (Add USE Flags as mentioned [here](https://wiki.gentoo.org/wiki/Mpv#USE_flags))
         sudo emerge --ask media-video/mpv` 

  - Note: make sure to install a version of [**mpv**](https://mpv.io/) that was released after June 2021, older versions [might not work](https://github.com/bloc97/Anime4K/issues/134).  
  
  2. Clone the repo using `git clone https://github.com/bloc97/Anime4K.git` , or download the archive files in the [Releases](https://github.com/bloc97/Anime4K/releases)

  3. Create a new `shaders` directory in `~/.config/mpv` and move the the `.glsl` shaders there
      `mv path/to/glsl/stuff ~/.config/mpv/shaders`

   ![image](https://user-images.githubusercontent.com/45941793/162597836-22de46b1-fd04-4054-a5ec-f83452ed4e13.png)


  4. Create an `mpv.conf` file in `~/.config/mpv` if not already present (Follow [this guide](https://wiki.archlinux.org/title/mpv#General_settings) to optimize your configuration.)

  5. Create an `input.conf` file in `~/.config/mpv` if not already present and paste one of the following code blocks inside the file:

### Flatpak
Setting up flatpak if not already configured, from [here](https://www.flatpak.org/setup/) 

On flatpak mpv, all config files, shaders and scripts have different directories:-  

 `~/.var/app/io.mpv.Mpv/config/mpv`  
 `~/.var/app/io.mpv.Mpv/config/mpv/mpv.conf`  
 `~/.var/app/io.mpv.Mpv/config/mpv/input.conf`  
 `~/.var/app/io.mpv.Mpv/config/mpv/scripts`  
 `~/.var/app/io.mpv.Mpv/config/mpv/shaders`  
 
 ![image](https://user-images.githubusercontent.com/88484339/163166658-38c41daa-f543-43b5-a06c-eddf21bcafb7.png)
 
 Tip:-
 Create a `mpv` folder, put all your files and folders(conf, shaders, scripts etc.) in there and copy/paste `mpv` folder to the `~/.var/app/io.mpv.Mpv/config/`  
 You can also do the same for non-flatpak mpv :-)

----
#### **Optimized shaders for higher-end GPU:**  
*(Eg. GTX 1080, RTX 2070, RTX 3060, RX 590, Vega 56, 5700XT, 6600XT)*  
*If upscaling to resolutions smaller than 4K, lower end GPUs can be used.*  
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"
CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"
CTRL+6 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```
____
**Optimized shaders for lower-end GPU:**  
*(Eg. GTX 980, GTX 1060, RX 570)  
These specs are approximated (and overestimated just in case) using TFLOPS, community benchmarks are needed...*  
*If upscaling to resolutions smaller than 4K, lower end GPUs can be used.*  
```
CTRL+1 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"
CTRL+2 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"
CTRL+3 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"
CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_Soft_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"
CTRL+6 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"

CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```
____
## Usage Instructions for Anime4K

  1. For Anime4K v4.x, instead of activating a single shader, you should use a combination of shaders.<br/>Add one of the following code blocks to `input.conf` to allow enabling the shaders:

  2. Anime4K v4.x has 3 major modes: A, B and C. To enable one of the modes, press CTRL+1 for mode A, CTRL+2 for B and so on. CTRL+0 will clear and disable all the shaders. Each mode is optimized for a different class of anime degradations, explanations are further down (soon in the wiki). For now you can just try each mode (starting from A) and use the one that looks the best.
  3. To verify the installation was correctly done, enable one of the Anime4K modes and use the MPV profiler to check if there are a few shaders with the name Anime4K running. To access the profiler, press Shift+I and then 2 on the keyboard's top row.  
This is what you should see (this example is from the v4.0.1, but also applies to newer versions):  
![image](https://user-images.githubusercontent.com/88484339/163173769-e6e616ec-b465-4f5f-820e-3abe056637b0.png)

  4. For advanced usage and more customization options, see the [Advanced Usage Instructions](GLSL_Instructions_Advanced.md) page.
