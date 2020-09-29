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

## Real-Time Denoising (Experimental, WIP)
The upcoming version 3.2 will focus on denoising. One version ([Heavy-CNN-L](https://github.com/bloc97/Anime4K/blob/master/glsl/Denoise/Anime4K_Denoise_Heavy_CNN_L.glsl)) of the experimental denoiser is released for preview. This version is for heavily compressed video. 

Note that it will likely change/improve upon release. The main focus will be speed, while also keeping a good quality.  
The new denoisers are/will be trained using a mix of the [SYNLA Dataset](https://github.com/bloc97/SYNLA-Dataset), [DIV2K Dataset](https://data.vision.ee.ethz.ch/cvl/DIV2K/), In-The-Wild Images and a tiny subset of the [Danbooru2019 Dataset](https://www.gwern.net/Danbooru2019).


![Comparison](results/Comparisons/Bird_Denoise/Compare.png?raw=true)

\**Note: Here it is evident that PSNR is not always the best indicator of perceived image quality. The waifu2x denoiser looks shaper, but hallucinates many artifacts, especially near line edges.*


## Real-Time Upscalers Comparison

The new Anime4K upscalers were trained using the [SYNLA Dataset](https://github.com/bloc97/SYNLA-Dataset). They were designed to be extremely efficient at using GPU shader cores (extremely thin, densely connected CNNs). All three versions outperform NGU and FSRCNNX both in upscale quality and speed while also keeping the number of parameters low, as seen in the test image below. This test image was not part of the training dataset, nor is it used as validation for hyperparameter tuning. Performance benchmarks are based on 1080p->4K upscaling and were performed using an AMD Vega 64 GPU.

The low resolution (LR) images are generated using the average area downscaling operation, which is the correct downscaling operation when we want to avoid using low pass filtering. Low pass filtering with bicubic/lanczos downscaling works well for natural images, but will destroy fine details in line art. The operation used is equivalent to `interpolation = INTER_AREA` in **OpenCV** and `-sws_flags area` in **FFmpeg**. <ins>Note that this operation is only equivalent to bilinear if and only if the downscaling ratio is exactly 2.</ins>

The correctness of average area downscaling is especially apparant as Anime4K-L was trained on average area downscaling only, and it generalizes well on unseen bicubic/lanczos degradation (24.94->24.81dB), while FSRCNNX-8-LineArt and waifu2x-CUNet were trained on bicubic/lanczos degradation only and do not generalize well for the unseen average area downscaling. PSNR of (24.93->24.47dB) and (26.02->25.61dB) respectively. [Link to results file.](https://github.com/bloc97/Anime4K/blob/master/results/Comparisons/Bird_FFmpeg/RESULTS.txt)

It has also come to our attention that many anime might have been suboptimally downscaled using the aforementioned low pass + bicubic method, as it is the default operation of FFmpeg. We will tackle this problem in v3.3 (after the v3.2 denoising update) by training the neural network with many different downscaling operations.

#### Comparison Table
First in each category is highlighted in brackets.

Algorithm | x2 PSNR (dB) ↑ | Runtime @4K (ms) ↓ | Parameters ↓
-- | -- | -- | --
[Bilinear](results/Comparisons/Bird/Bilinear.png) | 23.03 | 0 | 0
[ravu-r4](results/Comparisons/Bird/ravu-r4.png) | 24.09 | 3.6 | 41.4k
[FSRCNNX-16](results/Comparisons/Bird/FSRCNNX-16.png) | 24.57 | 30.4 | 10.5k
[NGU-Sharp-High](results/Comparisons/Bird/NGU-Sharp-High.png) | 24.69 | 11 | ?
[Anime4K-M](results/Comparisons/Bird/Anime4K-M.png) | 24.73 | **[1.5]** | **[1.6k]**
[Anime4K-L](results/Comparisons/Bird/Anime4K-L.png) | 24.94 | 2.5 | 2.9k
[Anime4K-UL](results/Comparisons/Bird/Anime4K-UL.png) | **[25.14]** | 10.7 | 15.9k
[waifu2x-CUNet](results/Comparisons/Bird/waifu2x-CUNet.png) | **[25.61]**\* | >1000 | 1283.3k

[Link to results file](https://github.com/bloc97/Anime4K/blob/master/results/Comparisons/Bird/RESULTS.txt)

\**waifu2x is technically first in PSNR, but it is not a realtime algorithm and is 80 times larger than Anime4K-UL. It is included only for comparison purposes.*

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
