# Anime4K

Anime4K is a set of open-source, high-quality real-time anime upscaling/denoising algorithms that can be implemented in any programming language.

The simplicity and speed of Anime4K allows the user to watch upscaled anime in real time, as we believe in preserving original content and promoting freedom of choice for all anime fans. Re-encoding anime into 4K should be avoided as it is non-reversible, potentially damages original content by introducing artifacts, takes up to O(n<sup>2</sup>) more disk space and more importantly, does so without any meaningful decrease in entropy (lost information is lost).


![Thumbnail Image](results/Main.png?raw=true)

***Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact us at 	anime4k.upscale@gmail.com and we will gladly take it down.***


## Upcoming v3.0
The monolithic Anime4K shader will be broken into modular components, allowing customization for specific types of anime and/or personal taste.

What's new:
 - A complete overhaul of the algorithm(s) for speed, quality and efficiency.
 - Real-time, high quality line art CNN upscalers. *(6 variants)*
 - Line art deblurring shaders. *("blind deconvolution")*
 - Denoising algorithms. *(Bilateral Mode and CNN variants)*
 - Blind resampling artifact reduction algorithms. *(For badly resampled anime.)*
 - Experimental line darkening and line thinning algorithm. *(For perceptual quality. We perceive thinner/darker lines as perceptually higher quality, even if it might not be the case.)*

Please consider the rest of the README outdated until it is updated.
The files are already available for anyone to play with, but usage instructions are not yet done.

![Comparison](results/Comparisons_3.0/Bird/Compare.png?raw=true)

## Notice

### This current README is outdated. I don't have the time to update the preprint and the comparisons for the major changes to the algorithm in the latest stable v2.1 version yet. Most issues related to aliasing and texture loss are solved in the latest version of the algorithm. A more rigorous and in-depth preprint is coming soon.

We understand that this algorithm is far from perfect, and are working towards a hybrid approach (using Machine Learning) to improve Anime4K. 

The greatest difficulties encountered right now are caused by these issues that other media does not suffer from:

 - Lack of ground truth (No True 4K Anime)
 - Few true 1080p anime (Even some anime mastered at 1080p have sprites that were downsampled)
 - Non-1080p anime are upsampled to 1080p using simple algorithms, resulting in a blurry 1080p image. Our algorithm has to detect this. (Main reason why waifu2x does not work well on anime)
 - UV channels of anime are subsampled (4:2:0), which means the color channels of 1080p anime are in fact 540p, thus there is a lack of 1080p ground truth for the UV channels.
 - Simulating H.264/H.265 compression artifacts (for analysis and denoising) is not trivial and is relatively time-consuming.
 - Due to the workflow of animation studios and their lack of time/budget, resampling artifacts of individual sprites are present in many modern anime.
 - Speed (preferably real-time) is paramount, since we do not want to re-encode video each time the algorithm improves. There is also less risk of permanently altering original content.
 - So on...

However, we still believe by shrinking the size of VDSR or FSRCNN and using an hybrid approach we can achieve good results.  
Stay tuned for more info!
 
## GLSL Usage Instructions (MPV)

This implementation is **cross platform**.

### [GLSL Installation](GLSL_Instructions.md)

Note for developers: For performance, the GLSL shaders use the `POSTKERNEL` texture to store the gradient. You might need to make a backup of the `POSTKERNEL` texture before applying these shaders and restore it after if your other shaders or rendering engine uses the `POSTKERNEL` texture for other purposes. (In MPV's case, it gets ignored.)

## HLSL Usage Instructions (MPC-BE with madVR)

This implementation is **only for Windows**.

This implementation is also **outdated**, the latest version is developped on GLSL.

### [HLSL Installation](HLSL_Instructions.md)  

Note for developers: For performance, the HLSL shaders use the Alpha channel to store the gradient. You might need to make a backup of the alpha channel before applying these shaders and restore it after if your rendering engine uses the alpha channel for other purposes. (In MPC-BE's case, it gets ignored.)

## Java Usage Instructions (Standalone)

This implementation is **outdated**, the latest version is developped on GLSL.

### [Java Installation](Java_Instructions.md)

Click on the link above to read Java version installation and usage instructions.

## Projects that use Anime4K
 - https://github.com/yeataro/TD-Anime4K (Anime4K for TouchDesigner)
 - https://github.com/keijiro/UnityAnime4K (Anime4K for Unity)
 - https://github.com/net2cn/Anime4KSharp (Anime4K Re-Implemented in C#)
 - https://github.com/andraantariksa/Anime4K-rs (Anime4K Re-Implemented in Rust)
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

### How does it *actually actually* work?

There's an excellent write-up by [shi-yan](https://github.com/shi-yan) that describes the (original v0.9) algorithm in detail (in fact better than in the preprint), with interactive sliders. See for yourself! https://epiphany.pub/@shi-yan/anime4k

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

### Note for those who think this is not a 'upscaling' algorithm.

[Explanation](Upscaling.md)

TL;DR

Sharpening, De-Blurring and Super-Resolution are equivalent.  
Anime4K can de-blur, and is equivalent to a SR algorithm.  
A Super-Resolution algorithm can do upscaling.  
Thus, Anime4K is an upscaling algorithm.
