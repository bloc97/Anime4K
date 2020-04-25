# Anime4K

Anime4K is a set of open-source, high-quality real-time anime upscaling/denoising algorithms that can be implemented in any programming language.

The simplicity and speed of Anime4K allows the user to watch upscaled anime in real time, as we believe in preserving original content and promoting freedom of choice for all anime fans. Re-encoding anime into 4K should be avoided as it is non-reversible, potentially damages original content by introducing artifacts, takes up to O(n<sup>2</sup>) more disk space and more importantly, does so without any meaningful decrease in entropy (lost information is lost).


![Thumbnail Image](results/Main.png?raw=true)

***Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact us at 	anime4k.upscale@gmail.com and we will gladly take it down.***


## v3.0
The monolithic Anime4K shader is broken into modular components, allowing customization for specific types of anime and/or personal taste.

What's new:
 - A complete overhaul of the algorithm(s) for speed, quality and efficiency.
 - Real-time, high quality line art CNN upscalers. *(6 variants)*
 - Line art deblurring shaders. *("blind deconvolution")*
 - Denoising algorithms. *(Bilateral Mode and CNN variants)*
 - Blind resampling artifact reduction algorithms. *(For badly resampled anime.)*
 - Experimental line darkening and line thinning algorithm. *(For perceptual quality. We perceive thinner/darker lines as perceptually higher quality, even if it might not be the case.)*
 
**[Installation Instructions for GLSL/MPV (v3.0)](https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions_3.0.md)**  

Further details about each shader and its purpose will be released soon.

## Real-Time Upscalers Comparison

The new Anime4K upscalers were trained using the [SYNLA Dataset](https://github.com/bloc97/SYNLA-Dataset). They were designed to be extremely efficient at using GPU shader cores (extremely thin, densely connected CNNs). All three versions outperform NGU and FSRCNNX both in upscale quality and speed while also keeping the number of parameters low, as seen in the test image below. This test image was not part of the training dataset. Performance benchmarks are based on 1080p->4K upscaling and were performed using a AMD Vega 64 GPU.

![Comparison](results/Comparisons_3.0/Bird/Compare.png?raw=true)

\*FSRCNNX-56 failed to launch when playing back 1080p video.  
Erratum: The original comparison had the wrong amount of parameters for Anime4K L and UL variants. The correct number is 2.9K and 15.9K respectively.

Please consider the rest of the README outdated until it is updated.

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

## HLSL Usage Instructions (MPC-BE with madVR)

This implementation is **only for Windows**.

This implementation is **outdated**, the latest version is developped on GLSL.

### [HLSL Installation](HLSL_Instructions.md)  

Note for developers: For performance, the HLSL shaders use the Alpha channel to store the gradient. You might need to make a backup of the alpha channel before applying these shaders and restore it after if your rendering engine uses the alpha channel for other purposes. (In MPC-BE's case, it gets ignored.)

## Java Usage Instructions (Standalone)

This implementation is also **outdated**, the latest version is developped on GLSL.

### [Java Installation](Java_Instructions.md)

Click on the link above to read Java version installation and usage instructions.

## Projects that use Anime4K
 - https://github.com/yeataro/TD-Anime4K (Anime4K for TouchDesigner)
 - https://github.com/keijiro/UnityAnime4K (Anime4K for Unity)
 - https://github.com/net2cn/Anime4KSharp (Anime4K Re-Implemented in C#)
 - https://github.com/andraantariksa/Anime4K-rs (Anime4K Re-Implemented in Rust)
 - https://github.com/k4yt3x/video2x (Anime Video Upscaling Pipeline)
