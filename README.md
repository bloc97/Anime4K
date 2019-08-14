# Anime4K

Anime4K is a state-of-the-art open-source high-quality real-time anime upscaling algorithm that can be implemented in any programming language, anywhere.  

![Thumbnail Image](results/Main.png?raw=true)
*State of the art as of August 2019, this will unquestionably be outperformed very soon.*


#### *Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact me and I will gladly take it down.*

![Comparison](results/Comparisons/1_time.png?raw=true)

<br/>
<br/>

# HLSL Usage Instructions (MPC-BE with madVR)  
**Windows Only**  
# [HLSL Installation](HLSL_Instructions.md)

# Java Usage Instructions (Standalone)
Currently unavailable.  
Unfinished, Still cleaning and commenting the code.  
# [Java Installation](Java_Instructions.md)


<br/>
<br/>
<br/>
<br/>

## FAQ
**Why not just use waifu2x?**  
-waifu2x is too slow for real time applications.  

**Why not just use madVR with NGU?**  
-NGU is proprietary, this algorithm is licensed under MIT.  

**Where are the PNSR/SSIM metrics?**  
-There are no ground truths of 4K anime.  

**I think the results are worse!**  
-Surely some people like sharper edges, some like softer ones. Do try it yourself on a few anime before reaching a definite conclusion. People *tend* to prefer sharper edges. Also, seeing the comparisons on a 1080p screen is not representative of the final results on a 4K screen, the pixel density and sharpness of the final image is simply not comparable.


# Psudo-Preprint Preview

[Read Full Preprint Here](Preprint.md)

B. Peng  
August 2019  

*Ad perpetuam memoriam of all who perished in the Kyoto Animation arson attack.*  

## Table of Contents

[Abstract](Preprint.md#abstract)  
[Introduction](Preprint.md#introduction)  
[Proposed Method](Preprint.md#proposed-method)  
[Results and Upscale Examples](Preprint.md#results)  
[Discussion](Preprint.md#discussion)  
[Analysis and Comparison to Other Algorithms](Preprint.md#analysis)  


## Abstract
We present a state-of-the-art high-quality real-time SISR algorithm designed to work with japanese animation and cartoons that is extremely fast *(~3ms with Vega 64 GPU)*, temporally coherent, simple to implement *(~100 lines of code)*, yet very effective. We find it surprising that this method is not currently used 'en masse', since the intuition leading us to this algorithm is very straightforward.  
Remarkably, the proposed method does not use any machine-learning or statistical approach, and is tailored to content that puts importance to well defined lines/edges while tolerates a sacrifice of the finer textures. The proposed algorithm can be quickly described as an iterative algorithm that treats color information as a heightmap and 'pushes' pixels towards probable edges using gradient-ascent. This is very likely what learning-based approaches are already doing under the hood (eg. VDSR<sup>**[1]**</sup>, waifu2x<sup>**[2]**</sup>).

[Read Full Preprint Here](Preprint.md#introduction)
