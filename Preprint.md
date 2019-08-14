

# Psudo-Preprint 

B. Peng  
August 2019  

*Ad perpetuam memoriam of all who perished in the Kyoto Animation arson attack.*  

## Table of Contents

[Abstract](#abstract)  
[Introduction](#introduction)  
[Proposed Method](#proposed-method)  
[Results and Upscale Examples](#results)  
[Discussion](#discussion)  
[Analysis and Comparison to Other Algorithms](#analysis)  


## Abstract
We present a state-of-the-art high-quality real-time SISR alorithm designed to work with japanese animation and cartoons that is extremely fast *(~3ms with Vega 64 GPU)*, temporally coherent, simple to implement *(~100 lines of code)*, yet very effective. We find it surprising that this method is not currently used 'en masse', since the intuition leading us to this algorithm is very straightforward.  

Remarkably, the proposed method does not use any machine-learning or statistical approach, and is tailored to content that puts importance to well defined lines/edges while tolerates a sacrifice of the finer textures. The proposed algorithm can be quickly described as an iterative algorithm that treats color information as a heightmap and 'pushes' pixels towards probable edges using gradient-ascent. This is very likely what learning-based approaches are already doing under the hood (eg. VDSR<sup>**[1]**</sup>, waifu2x<sup>**[2]**</sup>).


## Introduction
Our primary motivation is to upscale 1080p anime content for 4K screens. Current upscaling algorithms<sup>**[4]**</sup> are unsuited for real-time anime upscaling due to numerous factors.  

Using existing kernel algorithms alone such as Bicubic or xBR<sup>**[5]**</sup> produces unsatisfactory results when applied to anime, they were designed for other content in mind and tend to soften edges, which is unacceptable for anime.  

Using traditionnal 'unblurring' or 'sharpening' techniques causes overshoot<sup>**[3]**</sup> to appear near edges, which distracts the viewer and reduces the perceptual quality of the picture.  

Learning-based approaches (such as waifu2x, VDSR, EDSR, etc.) are a few orders of magnitude too slow for real-time (<30ms) applications, especially at UHD resolutions. Furthermore, the resulting algorithm outputs good quality upscales of 720p anime for 1080p screens, potentially allowing users to save disk space and/or network bandwidth by only archiving 720p encodes.

To further complicate the issue, 1080p anime is often not true 1080p. They are usually mastered in the studio at around 900p, then upscaled to 1080p for the final product. Some exceptions include blu-ray masters of full-length animation films.

### Existing algorithms
As a general rule, an image can be decomposed into two parts, its low frequency components ***LR_U*** and a high frequency residual ***r***.

![Image Decomposition](results/Image_Decomposition.png?raw=true)

Intuitively, single image super-resolution is defined as recovering high-frequency residuals ***r*** using the low frequency data ***LR_U*** (the blurry, low resolution image).  
Common edge refinement algorithms such as unsharp masking<sup>**[6]**</sup> take the low resolution image, extract the low resolution image's residual by computing the difference between the low resolution image with a even lower resolution of that image, then it thins and sharpens that residual to finally add it to **LR_U**. This method creates ringing and overshoot commonly seen on existing sharpening algorithms. We need something better that does not distract the viewer.  

Learning-based algorithms take in **LR_U** and try to predict the residual ***r*** with a neural network, a sparse dictionnary or look for self similarity in the image. Unfortuately learning based methods are for now too slow for real-time applications, but we cannot ignore their effectiveness. Algorithms such as waifu2x or VDSR vastly outperforms any other general-purpose upscaling algorithms.  

However, we will take advantage of the fact that our upscaling algorithm only needs to work on a **single** type of content (animation), thus we might have a chance to outperform learning-based algorithm.


## Proposed Method

Generally, animation frames do not contain a lot of textures, they are mostly composed of flat shaded objects and lines. Thus, a human can quickly recongnize a low-quality upscale of an anime, since even slight bit of bluriness is noticeable.

Instead of going for a general purpose upscaling algorithm, we decided to find a good edge-refinement algorithm. Crisp edges are more important to anime upscaling than recovering small details such as texture.

By looking at the failure cases of existing edge refinement algorithms, we conclude that if predicted the residual is ever slightly wrong, we see ringing and overshoot on the final image. Thus, we took a different approach.


As a general rule, the less blurry an image is, the thinner the residual lines. To take advantage of that fact, our algorithm will try to minimize the residuals' line thickness. However, having a thin residual is useless, since applying an arbitrarily transformed residual to **LR_U** is wrong and meaningless (we can't compute **HR** with only a residual, we need its corresponding **LR_U**). But, we can use this idea to define an objective function that seeks to minimize that image's residual thickness.

![Residuals Comparison](results/Residuals_Comparison.png?raw=true)

The main objective is to modify **LR_U** (the blurry image) until its residual becomes thinnest, giving us one of the possible **HR** (sharp) images.

Our algorithm will simply take as input **LR_U** and its residual, push the residual's pixels so that the lines becomes thinner. For each 'push' operation performed on the residual, we do the same on the color image. The residual will serve as a guide where to push. This has the effect of iteratively maximizing the gradients of an image, which mathematically is equivalent to minimizing blur, but without overshoot or rining artifacts commonly found on traditional 'unblurring' and 'sharpening' approaches.

Pseudocode:
```
  for each pixel on the image:
    for each direction (north, northeast, east, etc.):
      using the residual, if an edge is found:
        push the residual pixel in the current direction
        push the color pixel in the current direction
```

One trick our algorithm uses to improve performance is to use a sobel filter to approximate the image's residual instead of computing the residual with a gaussian filter, as computing a gaussian kernel is more expensive. Furthermore, minimizing the sobel gradient is mathematically similar (but not equivalent!) to minimizing the residual. This modification yielded no quality degradation on visual inspection.


An advantage of this algorithm is the fact it is scale-independant. The anime could be incorrectly upscaled beforehand (double upscaling, or even downscaled then upscaled), and this algorithm will still detect the blurry edges and refine them. Thus, the image can be upscaled in advance with any algorithm the user prefers (Bilinear, Jinc, xBR, or even waifu2x), this algorithm will then correctly refine the edges and remove blur. Running this algorithm on animes mastered at 900p makes the result look like a true 1080p anime.
For a stronger deblur, we simply run the algorithm again. This algorithm iteratively sharpens the image.

However, for 2x upscales, we noticed that the lines were usually too thick and looked unnatural (since blur usually spread dark lines outwards, making them thicker), thus we added a pre-pass to thin lines. This pass is not integral to the algorithm and can be safely removed by the user if wishes to keep the thick lines.  

We have implemented this algorithm both in Java and HLSL/C, they can be found in this repo.
The Java version can be used as an API to upscale images, while the HLSL code can be used as custom shaders for any media player supporting HLSL shaders. (In particular MPC-HC and MPC-BE with madVR)


## Results

To our surprise, such a simple method produced a exceptionally effective algorithm for unblurring and upscaling anime. It is not as good as waifu2x for recovering small details, but is very good at reconstructing sharp edges from blurry lines.  
Furthermore, due to the simplicity of this algorithm, running it on an GPU (*AMD RX Vega 64*) takes a mere 3 miliseconds, allowing us to upscale anime in real time. Even running on much less powerful integrated laptop GPUs (*Ryzen 5 2500U APU with Vega 8*) only takes 9 miliseconds.  
Instead of needing to upscale beforehand, the user can simply watch the anime with our algorithm running. This algorithm can potentially be implemented on phones or even run directly on the CPU if the user does not have a GPU.


Here are a few randomly selected comparisons:  
*Unless otherwise specified, all Anime4K upscales in comparisons are pre-upscaled with the Jinc algorithm found in madVR. The NGU variant used is NGU Sharp.*

### 1080p to 4K
![Upscale Comparison 0](results/Comparisons/0.png?raw=true)

![Upscale Comparison 1](results/Comparisons/1.png?raw=true)

![Upscale Comparison 2](results/Comparisons/2.png?raw=true)

![Upscale Comparison 3](results/Comparisons/3.png?raw=true)

### 720p to 1080p
![Upscale Comparison 4](results/Comparisons/7_1080.png?raw=true)

![Upscale Comparison 5](results/Comparisons/8_1080.png?raw=true)


### 480p to 1080p (A bit harder)

![Upscale Comparison 6](results/Comparisons/4.png?raw=true)

![Upscale Comparison 7](results/Comparisons/9.png?raw=true)

### 720p to 4K (Torture test)

![Upscale Comparison 8](results/Comparisons/7_4k.png?raw=true)

![Upscale Comparison 9](results/Comparisons/8_4k.png?raw=true)

### Art upscaling (Anime style)

Other algorithms are not shown as they perform poorly for art upscaling and are perceptually similar to bilinear.  

![Upscale Comparison 10](results/Comparisons/Art_0.png?raw=true)

![Upscale Comparison 11](results/Comparisons/Art_1_1.png?raw=true)

*More comparisons can be found in the appendix, and the raw images can be found in the repo under [/results/Upscale_Examples/](https://github.com/bloc97/Anime4K/tree/master/results/Upscale_Examples)*


## Discussion
Our algorithm can better recover sharp edges from all the pictures, even compared to waifu2x since it was specially tailored for this purpose.

However, a big weakness of our algorithm shows when we try to recover small details present in anime style art. waifu2x outperformed our algorithm by a large margin when there is texture detail, however since upscaling art was not our main goal, our results are acceptable.  
Furthermore, since our algorithm is scale-independant, we can apply it after running waifu2x, further enhancing and sharpening the edges.  

Then, as predicted, the bigger the upscaling scale, the harder it is for our algorithm. (Also harder for other algorithms) It succesfully sharpens the edges but cannot recover  sharp corners and texture, making the picture look like a pastel painting. Some people might like this style, some might not.  

One failure case of our algorithm is it tries to maximize soft gradients in the image, producing sharp bands of different colours if allowed to run for large amounts of iterations. A better edge detection will surely get rid of this problem.  

Interesting enough, waifu2x performed very poorly on anime. A plausible explaination is that the network was simply not trained to upscale these types of images. Usually anime style art have sharper lines and contain much more small details/textures compared to anime. The distribution of images used to train waifu2x must have been mostly art images from sites like DevianArt/Danbooru/Pixiv, and not anime.  
Furthermore, supervised training for a neural network to do 4K upscaling is currently not possible due to a lack of ground truth, there is simply no 4K anime yet! Unsupervised methods currently do not yield good enough quality to be used in practice. We will have to wait, until then, we believe our algorithm is state-of-the-art for real-time anime upscaling.


## Analysis

After a quick double blind test involving a few individuals, we were able to conjure up this (not-so-accurate) relative graph.  

Anime4K used as a standalone upscaling algorithm (Bilinear + Anime4K) already outperforms other more complex algorithms. With a little help (Jinc or xBR), it quickly becomes state of the art in the real time category.  

![Relative Quality Comparison Graph](results/Graph.png?raw=true)


## Conclusion
In conclusion, while our algorithm is very simple, it is also very good at upscaling anime within a short time budget. We are certain that some refinement (such as a better edge detection algorithm) will reduce artifacts, but that is left for another time. If the reader is interested enough, we encourage analyzing and improving this algorithm.


## Sources
(1) *Jiwon Kim, Jung Kwon Lee, Kyoung Mu Lee*, [**Accurate Image Super-Resolution Using Very Deep Convolutional Networks**](https://arxiv.org/abs/1511.04587)  
(2) *nagadomi*, [**waifu2x, Image Super-Resolution for Anime-Style Art**](https://github.com/nagadomi/waifu2x)  
(3) *Wikipedia*, [**Overshoot (signal)**](https://en.wikipedia.org/wiki/Overshoot_(signal))  
(4) *Wikipedia*, [**Image scaling**](https://en.wikipedia.org/wiki/Image_scaling)  
(5) *Wikipedia*, [**Pixel-art scaling algorithms**](https://en.wikipedia.org/wiki/Pixel-art_scaling_algorithms)  
(6) *Wikipedia*, [**Unsharp masking**](https://en.wikipedia.org/wiki/Unsharp_masking)

## Appendix

### More Upscale Comparisons

*The raw images can be found in the repo under [/results/Upscale_Examples/](https://github.com/bloc97/Anime4K/tree/master/results/Upscale_Examples)*

![Upscale Comparison](results/Comparisons/5.png?raw=true)
![Upscale Comparison](results/Comparisons/6.png?raw=true)
![Upscale Comparison](results/Comparisons/10.png?raw=true)
![Upscale Comparison](results/Comparisons/11.png?raw=true)
![Upscale Comparison](results/Comparisons/12.png?raw=true)
![Upscale Comparison](results/Comparisons/13.png?raw=true)
![Upscale Comparison](results/Comparisons/14.png?raw=true)
![Upscale Comparison](results/Comparisons/15.png?raw=true)

![Upscale Comparison](results/Comparisons/Art_0_1.png?raw=true)
![Upscale Comparison](results/Comparisons/Art_1.png?raw=true)

