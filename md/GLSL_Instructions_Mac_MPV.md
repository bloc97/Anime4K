# Usage Instructions (GLSL / MPV) (v4.x)

## Installing and Setting Up Anime4K for mpv on Apple Silicon and Intel-based Mac

*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

1. Install mpv via [Homebrew](https://formulae.brew.sh/formula/mpv) or download the latest release [here](https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-latest.tar.gz).
    - **Note:** Only the Homebrew version is built for native Apple Silicon.
    - <details>
      <summary>Click Here for Homebrew Installation</summary>
      <ol type="1">
        <li>If Homebrew is not installed, follow the instructions at <a href="https://brew.sh">https://brew.sh</a> to install it.</li>
        <li>Keep the terminal window open and follow the instructions under "Next steps" to add Homebrew to your PATH.</li>
        <li>Follow the instructions at <a href="https://formulae.brew.sh/formula/mpv">https://formulae.brew.sh/formula/mpv</a> to install mpv.</li>
      </ol>
      </details>

2. Open mpv (this will create the mpv config file location for you).

3. Download the template files and extract them (open the `.zip` file).

    - **Optimized shaders for lower-end GPU:**  
      *(Eg. M1, M2, Intel chips)*
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_Low-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Mac_Linux_Low-end/input.conf">input.conf</a> and <a href="Template/GLSL_Mac_Linux_Low-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>

    - **Optimized shaders for higher-end GPU:**  
      *(Eg. M1 Pro, M1 Max, M1 Ultra, M2 Pro, M2 Max, Intel chips)*  
       (Untested, might still have performance issues)  
        - Download the template files [here](https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip).
        - <details>
          <summary>Or click here to install manually.</summary>
          <ul>
            <li>Copy & Paste the code from <a href="Template/GLSL_Mac_Linux_High-end/input.conf">input.conf</a> and <a href="Template/GLSL_Mac_Linux_High-end/mpv.conf">mpv.conf</a> in your <code>input.conf</code> and <code>mpv.conf</code> file.</li>
            <li>Then download and extract the shaders from <a href="https://github.com/bloc97/Anime4K/releases">releases</a> and put them in the <code>shaders</code> folder.</li>
         </ul>
         </details>

4. In the Finder on your Mac, choose `Go` > `Go to Folder...`
   
   <img width="500" src="Screenshots/Mac/Finder.png">

5. Paste `~/.config/mpv/` and hit Enter.
   
   <img width="500" src="Screenshots/Mac/mpv/location.png">

6. Move the `input.conf`, `mpv.conf`, and the `shaders` folder into the `mpv` folder.

   <img width="800" src="Screenshots/Mac/mpv/config.png">

7. That's it! Anime4K is now installed and ready to use.

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
