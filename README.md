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
 - Line art deblurring shaders. *("blind deconvolution")*
 - Denoising algorithms. *(Bilateral Mode and CNN variants)*
 - Blind resampling artifact reduction algorithms. *(For badly resampled anime.)*
 - Experimental line darkening and line thinning algorithm. *(For perceptual quality. We perceive thinner/darker lines as perceptually higher quality, even if it might not be the case.)*
 
**[Installation Instructions for GLSL/MPV](GLSL_Instructions.md)**  

Further details about each shader and its purpose will be released soon.

## Real-Time Upscalers Comparison

The new Anime4K upscalers were trained using the [SYNLA Dataset](https://github.com/bloc97/SYNLA-Dataset). They were designed to be extremely efficient at using GPU shader cores (extremely thin, densely connected CNNs). All three versions outperform NGU and FSRCNNX both in upscale quality and speed while also keeping the number of parameters low, as seen in the test image below. This test image was not part of the training dataset. Performance benchmarks are based on 1080p->4K upscaling and were performed using an AMD Vega 64 GPU.

*The complete images from this comparison can be found under [results/Comparisons/Bird](results/Comparisons/Bird).*

![Comparison](results/Comparisons/Bird/Compare.png?raw=true)

\*FSRCNNX-56 failed to launch when playing back 1080p video.  

## Projects that use Anime4K
*Note that they might be using an outdated version of Anime4K. There have been significant quality improvements since v3.*
 - https://github.com/yeataro/TD-Anime4K (Anime4K for TouchDesigner)
 - https://github.com/keijiro/UnityAnime4K (Anime4K for Unity)
 - https://github.com/net2cn/Anime4KSharp (Anime4K Re-Implemented in C#)
 - https://github.com/andraantariksa/Anime4K-rs (Anime4K Re-Implemented in Rust)
 - https://github.com/k4yt3x/video2x (Anime Video Upscaling Pipeline)
