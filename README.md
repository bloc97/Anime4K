# Anime4K

Anime4K is a state-of-the-art*, open-source, high-quality real-time anime upscaling algorithm that can be implemented in any programming language.

![Thumbnail Image](results/Main.png?raw=true)

*\*State of the art as of August 2019 in the real-time anime 4K upscaling category, the fastest at achieving reasonable quality. We do not claim this is a superior quality general purpose SISR algorithm compared to machine learning approaches.*

***Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact us at 	anime4k.upscale@gmail.com and we will gladly take it down.***

![Comparison](results/Comparisons/1_time.png?raw=true)

## Notice

We understand that this algorithm is far from perfect, and are working towards a hybrid approach (using Machine Learning) to improve Anime4K. 

The greatest difficulties encountered right now are caused by these issues that other media does not suffer from:

 - Lack of ground truth (No True 4K Anime)
 - Few true 1080p anime (Even some anime mastered at 1080p have sprites that were downsampled)
 - UV channels of anime are subsampled (4:2:0), which means the color channels of 1080p anime are in fact 540p, thus there is a lack of 1080p ground truth for the UV channels.
 - Simulating H.264/H.265 compression artifacts (for analysis and denoising) are not trivial and are relatively time-consuming to create.
 - Due to the workflow of animation studios and their lack of time/budget, resampling artifacts of individual sprites are present in many modern anime.
 - So on...

However, we still believe by shrinking the size of VDSR or FSRCNN and using an hybrid approach we can achieve good results.  
Stay tuned for more info!
 

## v1.0 Release Candidate

Reduced texture loss, aliasing and banding in Anime4K v1.0 RC at the cost of performance. It now takes 6ms. +2ms for line detection and +1ms for line targeted FXAA.

What's new:
 - A line detection algorithm.
 - Gradient maximization is only applied near lines using the line detector, instead of indiscriminately affecting the entire image. This has the effect of ignoring textures and out of focus elements.
  - Finally, one iteration of targeted FXAA is applied on the lines using the line detector to reduce aliasing.

![ComparisonRC](https://raw.githubusercontent.com/bloc97/Anime4K/master/results/Comparisons/0.9-1.0/0_RC.png)
![ComparisonRC](https://raw.githubusercontent.com/bloc97/Anime4K/master/results/Comparisons/0.9-1.0/1_RC.png)
![ComparisonRC](https://raw.githubusercontent.com/bloc97/Anime4K/master/results/Comparisons/0.9-1.0/2_RC.png)
![ComparisonRC](https://raw.githubusercontent.com/bloc97/Anime4K/master/results/Comparisons/0.9-1.0/3_RC.png)

## HLSL Usage Instructions (MPC-BE with madVR)

This implementation is **only for Windows**.

### [HLSL Installation](HLSL_Instructions.md)  

Note for developers: For performance, the HLSL shaders use the Alpha channel to store the gradient. You might need to make a backup of the alpha channel before applying these shaders and restore it after if your rendering engine uses the alpha channel for other purposes. (In MPC-BE's case, it gets ignored.)

## GLSL Usage Instructions (MPV)

This implementation is **cross platform**.

### [GLSL Installation](GLSL_Instructions.md)

Note for developers: For performance, the GLSL shaders use the `POSTKERNEL` texture to store the gradient. You might need to make a backup of the `POSTKERNEL` texture before applying these shaders and restore it after if your other shaders or rendering engine uses the `POSTKERNEL` texture for other purposes. (In MPV's case, it gets ignored.)

## Java Usage Instructions (Standalone)

### [Java Installation](Java_Instructions.md)

Click on the link above to read Java version installation and usage instructions.

## Projects that use Anime4K
 - https://github.com/yeataro/TD-Anime4K (Anime4K for TouchDesigner)
 - https://github.com/keijiro/UnityAnime4K (Anime4K for Unity)
 - https://github.com/net2cn/Anime4KSharp (Anime4K Re-Implemented in C#)
 - https://github.com/k4yt3x/video2x (Anime Video Upscaling Pipeline)


## Pseudo-Preprint Preview

### [Read Full Pseudo-Preprint](Preprint.md)

B. Peng  
August 2019

*Ad perpetuam memoriam of all who perished in the Kyoto Animation arson attack.*

### Table of Contents

- [Abstract](Preprint.md#abstract)  
- [Introduction](Preprint.md#introduction)  
- [Proposed Method](Preprint.md#proposed-method)  
- [Results and Upscale Examples](Preprint.md#results)  
- [Discussion](Preprint.md#discussion)  
- [Analysis and Comparison to Other Algorithms](Preprint.md#analysis)  

### Abstract

We present a state-of-the-art high-quality real-time SISR algorithm designed to work with Japanese animation and cartoons that is extremely fast *(~3ms with Vega 64 GPU)*, temporally coherent, simple to implement *(~100 lines of code)*, yet very effective. We find it surprising that this method is not currently used 'en masse', since the intuition leading us to this algorithm is very straightforward.  
Remarkably, the proposed method does not use any machine-learning or statistical approach, and is tailored to content that puts importance to well defined lines/edges while tolerates a sacrifice of the finer textures. The proposed algorithm can be quickly described as an iterative algorithm that treats color information as a heightmap and 'pushes' pixels towards probable edges using gradient-ascent. This is very likely what learning-based approaches are already doing under the hood (eg. VDSR<sup>**[1]**</sup>, waifu2x<sup>**[2]**</sup>).

## FAQ

### Why not just use waifu2x

waifu2x is too slow for real time applications.

### Why not just use madVR with NGU

NGU is proprietary, this algorithm is licensed under MIT.

### How does FSRCNNX compare to this

Since it performs poorly (perceptually, for anime) compared to other algorithms, it was left out of our visual comparisons.

![ComparisonRC](https://raw.githubusercontent.com/bloc97/Anime4K/master/results/Comparisons/FSRCNNX.png)

*Note: FSRCNNX was not specifically trained/designed for anime. It is however a good general-purpose SISR algorithm for video.*

### Where are the PSNR/SSIM metrics

There are no ground truths of 4K anime.

### Why not do PSNR/SSIM on 480p->720p upscaling

[Story Time](FAQ_Detail.md)

Comparing PSNR/SSIM on 480p->720p upscales does not prove and is not a good indicator of 1080p->2160p upscaling quality. (Eg. poor performance of waifu2x on 1080p anime) 480p anime images have a lot of high frequency information (lines might be thinner than 1 pixel), while 1080p anime images have a lot of redundant information. 1080p->2160p upscaling on anime is thus objectively easier than 480p->720p.

### I think the results are worse than \<x>

Surely some people like sharper edges, some like softer ones. Do try it yourself on a few anime before reaching a definite conclusion. People *tend* to prefer sharper edges. Also, seeing the comparisons on a 1080p screen is not representative of the final results on a 4K screen, the pixel density and sharpness of the final image is simply not comparable.
