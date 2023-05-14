# Usage Instructions (GLSL / MPV) (v4.x)

## Installing and Setting Up Anime4K for Linux-based Distributions (and other Unix-like OS)

  1. Install `mpv` from repositories of your distribution, some of the common ones are mentioned here
      ### Fedora Silverblue
        1. Install the RPM-Fusion "free" repository, if not already installed, paste in the command below

            `sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm`

        2. Reboot and install `mpv`
        
        3. Reboot and continue to step 2
       
        ### Fedora
         sudo dnf install mpv

        ### Ubuntu and Derivatives
         sudo apt install mpv

        ### Arch and Derivatives
         sudo pacman -S mpv

        ### Gentoo (Add USE Flags as mentioned [here](https://wiki.gentoo.org/wiki/Mpv#USE_flags))
         sudo emerge --ask media-video/mpv` 

  - Note: make sure to install a version of [**mpv**](https://mpv.io/) that was released after June 2021, older versions [might not work](https://github.com/bloc97/Anime4K/issues/134).

2. Clone the repo using `git clone https://github.com/bloc97/Anime4K.git`, or download the template files and extract them.

    - **Optimized shaders for lower-end GPU:**  
      *(Eg. GTX 980, GTX 1060, RX 570)*
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_Low-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Mac_Linux_Low-end/input.conf">input.conf</a> and <a href="Template/GLSL_Mac_Linux_Low-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>

    - **Optimized shaders for higher-end GPU:**  
      *(Eg. GTX 1080, RTX 2070, RTX 3060, RX 590, Vega 56, 5700XT, 6600XT)*
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Mac_Linux_High-end/input.conf">input.conf</a> and <a href="Template/GLSL_Mac_Linux_High-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>

3. Navigate to `~/.config/mpv` and move the `input.conf`, `mpv.conf` and the `shaders` folder into the `mpv` directory.
   `mv path/to/stuff ~/.config/mpv`

   ![image](https://user-images.githubusercontent.com/45941793/162597836-22de46b1-fd04-4054-a5ec-f83452ed4e13.png)

____
## Quick Usage Instructions

1. Anime4K has 3 major modes: A, B, and C. Each mode is optimized for a different class of anime degradations.
    - Mode A is automatically enabled, if you use our template (this can be change in `mpv.conf`).

2. To enable each mode manually:
    - Press **CTRL+1** to enable Mode A (Optimized for 1080p Anime).
    - Press **CTRL+2** to enable Mode B (Optimized for 720p Anime).
    - Press **CTRL+3** to enable Mode C (Optimized for 480p Anime).
    - Press **CTRL+0** to clear all shaders (Disable Anime4K).
    
3. For more explanations and customization options, see the [Advanced Usage Instructions](GLSL_Instructions_Advanced.md#advanced-usage-instructions-glsl--mpv-v4x).
