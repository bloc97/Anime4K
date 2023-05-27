# Usage Instructions (GLSL / PLEX) (v4.x)

## Installing and Setting Up Anime4K for Plex on Windows

  1. Download `Plex for Windows` or `Plex HTPC (for Windows Home Theater PCs)` from [**here**](https://www.plex.tv/media-server-downloads/#plex-app).  
     - *Note: Only the desktop version of the app supports GLSL shaders.*
 
  2. Open `Plex` or `Plex HTPC` (this will create the config location for you).

  3. Download the template files, and extract it (open the .zip file).

     - **Optimized shaders for lower-end GPU:**  
      *(Eg. GTX 980, GTX 1060, RX 570)*
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Windows_Low-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Windows_Low-end/input.conf">input.conf</a> and <a href="Template/GLSL_Windows_Low-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>

     - **Optimized shaders for higher-end GPU:**  
      *(Eg. GTX 1080, RTX 2070, RTX 3060, RX 590, Vega 56, 5700XT, 6600XT)*
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Windows_High-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Windows_High-end/input.conf">input.conf</a> and <a href="Template/GLSL_Windows_High-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>
         
  4. Open File Explorer and type in `%LOCALAPPDATA%\Plex` or `%LOCALAPPDATA%\Plex HTPC`, then hit Enter.
 
     <img width="800" src="Screenshots/Windows/Plex/location.png">
     <img width="800" src="Screenshots/Windows/Plex HTPC/location.png">
     
  5. Move the `input.conf`, `mpv.conf` and the `shaders` folder into the into the `Plex` or `Plex HTPC` folder.

     <img width="800" src="Screenshots/Windows/Plex/config.png">
     <img width="800" src="Screenshots/Windows/Plex HTPC/config.png"> 
     
  6. That's it, Anime4K is now installed and ready to use!

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
