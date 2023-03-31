# Usage Instructions (GLSL / PLEX) (v4.x)

## Installing and setting up Anime4K for Plex on Apple Silicon and Intel-based Mac

  1. Download Plex for Mac or Plex HTPC (for macOS Home Theater PCs) from [**here**](https://www.plex.tv/media-server-downloads/#plex-app)  
     - *Note: Only the desktop version of the app supports GLSL shaders*
 
  2. Open Plex or Plex HTPC (this will create the Application Support location for you)

  3. Download the template files, and extract it (open the .zip file)
     - Optimized shaders for lower-end GPU: *Eg. M1, M2, Intel Chips*
       - Download template [**here**](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_Low-end.zip) or maually copy the code from [**input.conf**](Template/GLSL_Mac_Linux_Low-end/input.conf) and [**mpv.conf**](Template/GLSL_Mac_Linux_Low-end/mpv.conf)
     - Optimized shaders for higher-end GPU: *Eg. Pro, Max, and Ultra, Intel Chips* (Untested)
       - Download template [**here**](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip) or maually copy the code from [**input.conf**](Template/GLSL_Mac_Linux_High-end/input.conf) and [**mpv.conf**](Template/GLSL_Mac_Linux_High-end/mpv.conf)

  4. In the Finder on your Mac, choose Go > Go to Folder...<br>
     <img width="500" src="Screenshots/Mac/Finder.png">
     
  5. Paste `~/Library/Application Support/Plex/` or `~/Library/Application Support/Plex HTPC/` and hit Enter.<br>
     <img width="500" src="Screenshots/Mac/Plex/location.png"><br>
     <img width="500" src="Screenshots/Mac/Plex HTPC/location.png">
     
  6. Move the template files (input.conf, mpv.conf and the shaders folder) to the Plex or Plex HTPC folder.
     <img width="800" src="Screenshots/Mac/Plex/config.png"><br>
     <img width="800" src="Screenshots/Mac/Plex HTPC/config.png">
     
  7. That's it, Anime4K is now installed and ready to use!
     ____
     
## Quick Usage Instructions

  1. Anime4K has 3 Major Modes: A, B and C. Each mode is optimized for a different class of anime degradations. For more explanations and customization options, see the [**Advanced Usage Instructions**](md/GLSL_Instructions_Advanced.md#advanced-usage-instructions-glsl--mpv-v4x)<br>
     - By Default, Mode A is automatically enabled in our template (this can be change in mpv.conf)

  2. To enable each Mode manually
     - Press CTRL+1 to enable Mode A (best for 1080p anime)
     - Press CTRL+2 to enable Mode B (best for 720p anime)
     - Press CTRL+3 to enable Mode C (best for 480p anime)
     - Press CTRL+0 to clear all shaders (disable Anime4K)
