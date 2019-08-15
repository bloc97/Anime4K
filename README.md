# Anime4K

Anime4K is a state-of-the-art*, open-source, high-quality real-time anime upscaling algorithm that can be implemented in any programming language, anywhere.  

![Thumbnail Image](results/Main.png?raw=true)
*State of the art as of August 2019, this will unquestionably be outperformed very soon.*


#### *Disclaimer: All art assets used are for demonstration and educational purposes. All rights are reserved to their original owners. If you (as a person or a company) own the art and do not wish it to be associated with this project, please contact me and I will gladly take it down.*

\**State of the art in the realtime anime upscaling category, the fastest at acheiving reasonable quality. We do not claim this is a superior quality general purpose SISR algorithm compared to machine-learning approaches.*

![Comparison](results/Comparisons/1_time.png?raw=true)

<br/>
<br/>

# HLSL Usage Instructions (MPC-BE with madVR)  
**Windows Only**  
# [HLSL Installation](HLSL_Instructions.md)  
Note for developers: For performance, the HLSL shaders use the Alpha channel to store the gradient, you might need to make a backup of the the alpha channel before applying these shaders and restore it after if your rendering engine uses the alpha channel for other purposes. (In MPC-BE's case, it gets ignored.)  

# GLSL Usage Instructions (MPV)  
**Cross platform**  
# [GLSL Installation](GLSL_Instructions.md)  
Note for developers: For performance, the GLSL shaders use the `POSTKERNEL` texture to store the gradient, you might need to make a backup of the the `POSTKERNEL` texture before applying these shaders and restore it after if your other shaders or rendering engine uses the `POSTKERNEL` texture for other purposes. (In MPV's case, it gets ignored.)  

# Java Usage Instructions (Standalone)
# [Java Installation](Java_Instructions.md)


<br/>
<br/>
<br/>
<br/>

# [Read Full Pseudo-Preprint Here](Preprint.md)

## FAQ
**Why not just use waifu2x?**  
-waifu2x is too slow for real time applications.  

**Why not just use madVR with NGU?**  
-NGU is proprietary, this algorithm is licensed under MIT.  

**Where are the PSNR/SSIM metrics?**  
-There are no ground truths of 4K anime.  

# **Why not do PSNR/SSIM on 480p->720p upscaling?**  
-I get this question a lot, and let me clarify things. Usually when I try to demonstrate a point I try to do it in the extreme, so that the reasoning becomes very clear.  

Let's say in another hypothetical world (lets call it PixLand) all anime are just diagonal lines on a 2x2 image. So there are only two possible anime pictures possible in that world. Lets also say that in this world, all images are binary, no grayscale.  

![Demo 0](results/Demo/TwoAnimes.png?raw=true)

The people inhabiting PixLand, called Pixels, have never seen 4x4 anime, but they do know what 4x4 images look like, they've seen them in drawings, manga and the sort.  

One day, a few clever pixels publish an algorithm Diagonal4K. It is a very simple algorithm. It checks if the top left corner of the 2x2 anime is black, if so, produce a 4x4 image with a diagonal line running from the top left to bottom right. If the top left corner of the 2x2 anime is white, produce a 4x4 image with a diagonal line running from the top right to bottom left.  

![Demo 1](results/Demo/DiagonalUpscale.png?raw=true)

Most people are amazed, they've never seen such clarity in anime before! It has only been seen in 4x4 manga and 4x4 drawings. But, a few are skeptical (in a good way).  

-*"The lines are too long..."*, one skeptic says out loud.  
-*"This is nonsense! A diagonal 2x2 line upscaled must be curvy, it can't be straight!"*, another commented on Pixddit.  

They might be right, or wrong, we will never know. In fact it is impossible to know since 4x4 anime doesn't exist in their world, nor can we comprehend them as outsiders.  

We might look at the Pixels inhabiting PixLand in pity, but since each have their own preferences, we're not here to judge.  

Thus, to assess its true effectiveness with a metric, a few Pixels had the genius idea to downscale 2x2 anime into a single pixel and apply the algorithm to see if it produces 2x2 anime correctly.  

**As you've certainly realized, upscaling 1x1 anime into 2x2 with Diagonal2K does not make sense at all, and is not a good indicator of quality. There is no way the algorithm will recover the 2x2 anime with a single pixel.**  

Let's also say that in their world, downscaling is always done using the Nearest-Neighbour algorithm.  

Due to the small brains of Pixels, the authors of Diagonal4K do not realize that if the 1x1 image is black, it must be Anime 1, and if it were to be be white instead, Anime 2.  

But 4 years prior, another group of smart pixels used the power of machine learning to augment their small brains. Their algorithm sexyCircle2x, a pixel-network, learnt that 1x1 black image is Anime 1, and 1x1 black is Anime 2. It learnt the distribution of Animes, and correctly guesses what anime corresponds to what pixel color.  

People were dumbfounded. "Wow! It can basically generate anime!" "Incredible! Details out of thin air!" "Garbage In, Awesomeness out!"  

Back to the present, those Pixels dug out sexyCircle2x and begun their comparison. The pixel-network upscales 1x1 -> 2x2 correctly, while Diagonal4K does not. Thus they concluded that Diagonal4K must be inferior.  

![Demo 1](results/Demo/1x1-2x2.png?raw=true)

Applying sexyCircle2x to 2x2 anime also yields plausible 4x4 "anime", but they do not and will never know if it is truely anime. However they trust the algorithm since it is a pixel-network, and must be smarter than their small Pixel brains.  

So the results are:  
sexyCircle2x correctly upscales 1x1 -> 2x2  
sexyCircle2x upscales 2x2 -> 4x4, but some people do not like its output, as it always produces an X pattern. However most people accept its quality as the X pattern is a pleasing pattern to look at.  

While:  
Diagonal4K fails on 1x1 -> 2x2  
Diagonal4K upscales 2x2 -> 4x4 and preserves the line straightness, but some Pixels fervently dislike straight lines.  

![Demo 1](results/Demo/2x2-4x4.png?raw=true)

**Thus the question is: Is Diagonal4K an inferior algorithm compared sexyCircle2x?**  

I think this question is nonsensical! It is impossible to even tell which algorithm is best at upscaling 2x2 to 4x4.  

Of course, this example is very extreme, but the same principles applies here.  

Comparing PSNR/SSIM on 480p->720p upscales and then claiming that it is a good indicator of 1080p->2160p upscaling quality does not make sense. 480p images have a lot of high frequency information (lines might be thinner than 1 pixel), while 1080p images have a lot of redundant information. 1080p->2160p upscaling on anime is thus objectively easier than 480p->720p.  
 
Only each individual can really judge for themselves (not for others) if our algorithm is good or not.  
Some people prefer sharp lines and don't really mind the pastel painting look that Anime4K sometime produces, while some will certainly despise sharp lines and the pastel look. We're not here to judge the individual.  


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
