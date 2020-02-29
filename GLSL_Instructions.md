
# Usage Instructions (GLSL / MPV)
*If you wish to use another media player, look at their documentation on how to install GLSL shaders and modify the shader accordingly if needed.*

1- Install [**mpv**](https://mpv.io/)  
2- Download the .glsl shader files [**here**](https://github.com/bloc97/Anime4K/releases)  
3- Copy the .glsl files to `%AppData%\mpv\shaders` for Windows or `~/.config/mpv/shaders` for Linux.  
4- If `mpv.conf` does not exist in `%AppData%\mpv\` or `~/.config/mpv`, create an empty file and follow [**these instructions**](https://wiki.archlinux.org/index.php/Mpv#Configuration) to optimize your configuration.  
5- Add this line to `mpv.conf` to enable the shaders: `glsl-shaders="~~/shaders/Anime4K_Hybrid_v2.0RC.glsl"`  
The file name might vary depending on the version, rename it accordingly.

*Unlike HLSL, the GLSL shader can auto-detect the scaling factor and adjust its strength accordingly.*  
