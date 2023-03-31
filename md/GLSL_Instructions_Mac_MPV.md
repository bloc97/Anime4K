# Usage Instructions (GLSL / MPV) (v4.x)

## Installing and setting up Anime4K for mpv on Apple Silicon and Intel-based Mac
*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

  1. Install mpv via [**Homebrew**](https://formulae.brew.sh/formula/mpv) or download the latest release [**here**](https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-latest.tar.gz)
     - *Note: Only the Homebrew version are built for Native Apple Silicon*

  2. Open mpv (this will create the mpv config file location for you)

  3. Download the template files, and extract it (open the .zip file)
     - Optimized shaders for lower-end GPU: *Eg. M1, M2, Intel Chips*
       - Download template [**here**](Template/GLSL_Mac_Linux_Low-end.zip?raw=true) or maually copy the code from [**input.conf**](Template/GLSL_Mac_Linux_Low-end/input.conf) and [**mpv.conf**](Template/GLSL_Mac_Linux_Low-end/mpv.conf)
     - Optimized shaders for higher-end GPU: *Eg. Pro, Max, and Ultra, Intel Chips* (Untested)
       - Download template [**here**](Template/GLSL_Mac_Linux_High-end.zip?raw=true) or maually copy the code from [**input.conf**](Template/GLSL_Mac_Linux_High-end/input.conf) and [**mpv.conf**](Template/GLSL_Mac_Linux_High-end/mpv.conf)

  4. In the Finder on your Mac, choose Go > Go to Folder...<br>
     <img width="500" src="Screenshots/Mac/Finder.png">
     
  5. Paste `~/.config/mpv/` and hit Enter.<br>
     <img width="500" src="Screenshots/Mac/mpv/location.png">
     
  6. Move the template files (input.conf, mpv.conf and the shaders folder) to the mpv folder.
     <img width="800" src="Screenshots/Mac/mpv/config.png">
     
  7. That's it, Anime4K is now installed and ready to use!
     ____
     
## Quick Usage Instructions

  1. Anime4K has 3 Major Modes: A, B and C. Each mode is optimized for a different class of anime degradations, explanations are in [**Advanced Usage Instructions**](md/GLSL_Instructions_Advanced.md#advanced-usage-instructions-glsl--mpv-v4x)<br>
     - By Default, Mode A (best for 1080p anime) is automatically enabled in our template (this can be change in mpv.conf)

  2. To enable each Mode Manually
     - Press CTRL+1 to enable Mode A (1080p)
     - Press CTRL+2 to enable Mode B (720p)
     - Press CTRL+3 to enable Mode C (480p)
     - Press CTRL+0 to clear all shaders
