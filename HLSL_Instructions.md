
# Usage Instructions (HLSL)
*If you wish to use another media player, look at their documentation on how to install HLSL shaders and modify the shader accordingly if needed.*

1. Install [**MPC-HC**](https://github.com/clsid2/mpc-hc) or [**MPC-BE**](https://sourceforge.net/projects/mpcbe/) and [madVR](http://madvr.com/) (Optional, but good for quality)
1. (MPC-HC Only) Enable Full Floating Point Processing or Half Floating Point Processing in [Renderer Settings](https://trac.mpc-hc.org/wiki/New_Renderer_Settings).
1. Download the .hlsl shader files [**here**](https://github.com/bloc97/Anime4K/releases/download/v0.9/Anime4K_HLSL.zip)  
1. (MPC-BE Only) Copy the .hlsl files to `%AppData%\MPC-BE\Shaders`  
1. Add the shaders **(The order is important!)**   

![Step1](results/Step1.png?raw=true)

**Different screen resolutions need different shaders:**  
Smaller or equal to 1080p  
```
-Anime4K_ComputeLum  
-Anime4K_Push  
-Anime4K_ComputeGradient  
-Anime4K_PushGrad_Weak  
```
Larger than 1080p  
```
-Anime4K_ComputeLum  
-Anime4K_Push  
-Anime4K_ComputeGradient  
-Anime4K_PushGrad  
```

Note: *Anime4K_Push* is an optional pass that thins lines, it can be removed if the effect is unsatisfactory for certain anime.

![Step2](results/Step2.png?raw=true)


### If madVR is installed
*These are heavy on the GPU, do not use them if rendering times rise above 30ms*  

Settings used for all the comparisons:  
![Settings1](results/Settings1.png?raw=true)

![Settings1](results/Settings2.png?raw=true)
