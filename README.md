# Anime4K

Anime4K is a set of open-source, high-quality real-time anime upscaling/denoising algorithms that can be implemented in any programming language.

The simplicity and speed of Anime4K allows the user to watch upscaled anime in real time, as we believe in preserving original content and promoting freedom of choice for all anime fans. Re-encoding anime into 4K should be avoided as it is non-reversible, potentially damages original content by introducing artifacts, takes up to O(n<sup>2</sup>) more disk space and more importantly, does so without any meaningful decrease in entropy (lost information is lost).


![Thumbnail Image](results/Main.png?raw=true)

***Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact us at 	anime4k.upscale@gmail.com and we will gladly take it down.***


## v3
The monolithic Anime4K shader is broken into modular components, allowing customization for specific types of anime and/or personal taste.

What's new:
 - A complete overhaul of the algorithm(s) for speed, quality and efficiency.
 - Real-time, high quality line art CNN upscalers. *(6 variants)*
 - Line art deblurring shaders. *("blind deconvolution" and DTD shader)*
 - Denoising algorithms. *(Bilateral Mode and CNN variants)*
 - Blind resampling artifact reduction algorithms. *(For badly resampled anime.)*
 - Experimental line darkening and line thinning algorithm. *(For perceptual quality. We perceive thinner/darker lines as perceptually higher quality, even if it might not be the case.)*
 
**[Installation Instructions for GLSL/MPV](GLSL_Instructions.md)**  

[More information about each shader](https://github.com/bloc97/Anime4K/wiki).

## Real-Time Upscalers Comparison

The new Anime4K upscalers were trained using the [SYNLA Dataset](https://github.com/bloc97/SYNLA-Dataset). They were designed to be extremely efficient at using GPU shader cores (extremely thin, densely connected CNNs). All three versions outperform NGU and FSRCNNX both in upscale quality and speed while also keeping the number of parameters low, as seen in the test image below. This test image was not part of the training dataset. Performance benchmarks are based on 1080p->4K upscaling and were performed using an AMD Vega 64 GPU.

First in each category is highlighted in brackets.
Algorithm | x2 PSNR (dB) | Runtime (ms) | Parameters
-- | -- | -- | --
Bilinear | 23.03 | 0 | 0
ravu-r4 | 24.09 | 3.6 | 41.4k
FSRCNNX-16 | 24.57 | 30.4 | 10.5k
NGU-Sharp-High | 24.69 | 11 | ?
Anime4K-M | 24.73 | **[1.5]** | **[1.6k]**
Anime4K-L | 24.94 | 2.5 | 2.9k
Anime4K-UL | **[25.14]** | 10.7 | 15.9k

*The complete images from this comparison can be found under [results/Comparisons/Bird](results/Comparisons/Bird).*

![Comparison](results/Comparisons/Bird/Compare.png?raw=true)

\*FSRCNNX-56 failed to launch when playing back 1080p video.  

## Projects that use Anime4K
*Note that they might be using an outdated version of Anime4K. There have been significant quality improvements since v3.*
 - https://github.com/yeataro/TD-Anime4K (Anime4K for TouchDesigner)
 - https://github.com/keijiro/UnityAnime4K (Anime4K for Unity)
 - https://github.com/net2cn/Anime4KSharp (Anime4K Re-Implemented in C#)
 - https://github.com/andraantariksa/Anime4K-rs (Anime4K Re-Implemented in Rust)
 - https://github.com/TianZerL/Anime4KCPP (Anime4K & more algorithms implemented in C++)
 - https://github.com/k4yt3x/video2x (Anime Video Upscaling Pipeline)
