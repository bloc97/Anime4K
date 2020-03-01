
# Usage Instructions (GLSL / MPV)
*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

  1. Install [**mpv**](https://mpv.io/)  
  2. Download the .glsl shader files [**here**](https://github.com/bloc97/Anime4K/releases)  
  3. Copy the .glsl files to `%AppData%\mpv\shaders` for Windows or `~/.config/mpv/shaders` for Linux.  
  4. If `mpv.conf` does not exist in `%AppData%\mpv\` or `~/.config/mpv`, create an empty file and follow [**these instructions**](https://wiki.archlinux.org/index.php/Mpv#Configuration) to optimize your configuration.  
  5. Add this line to `mpv.conf` to enable the shaders: `glsl-shaders="~~/shaders/Anime4K_Hybrid_v2.0RC.glsl"`  
The file name might vary depending on the version, rename it accordingly.  
  6. To verify the installation was correctly done, use the MPV profiler to check if there are a few shaders with the name Anime4K running. To access the profiler, press Shift+I and then 2 on the keyboard's top row.  
This is what you should see (for v2.0RC2):  
![Profiler](results/MPV_Profiler.png?raw=true)


*Unlike HLSL, the GLSL shader can auto-detect the scaling factor and adjust its strength accordingly.*  
