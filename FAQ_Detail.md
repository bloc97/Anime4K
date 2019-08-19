
## Why not do PSNR/SSIM on 480p->720p upscaling

I get this question a lot, and let me clarify things. Usually when I try to demonstrate a point I try to do it in the extreme, so that the reasoning becomes very clear.

Let's say in another hypothetical world (lets call it PixLand) all anime are just diagonal lines on a 2x2 image. So there are only two possible anime pictures possible in that world. Lets also say that in this world, all images are binary, no grayscale.

![Demo 0](results/Demo/TwoAnimes.png?raw=true)

The people inhabiting PixLand, called Pixels, have never seen 4x4 anime, but they do know what 4x4 images look like, they've seen them in drawings, manga and the sort.

One day, a few clever pixels publish an algorithm Diagonal4K. It is a very simple algorithm. It checks if the top left corner of the 2x2 anime is black, if so, produce a 4x4 image with a diagonal line running from the top left to bottom right. If the top left corner of the 2x2 anime is white, produce a 4x4 image with a diagonal line running from the top right to bottom left.

![Demo 1](results/Demo/DiagonalUpscale.png?raw=true)

Most people are amazed, they've never seen such clarity in anime before! It has only been seen in 4x4 manga and 4x4 drawings. But, a few are skeptical (in a good way).

> *"The lines are too long..."*

One skeptic says out loud.

> *"This is nonsense! A diagonal 2x2 line upscaled must be curvy, it can't be straight!"*

Another commented on Pixddit.

They might be right, or wrong, we will never know. In fact it is impossible to know since 4x4 anime doesn't exist in their world, nor can we comprehend them as outsiders.

We might look at the Pixels inhabiting PixLand in pity, but since each have their own preferences, we're not here to judge.

Thus, to assess its true effectiveness with a metric, a few Pixels had the genius idea to downscale 2x2 anime into a single pixel and apply the algorithm to see if it produces 2x2 anime correctly.

**As you've certainly realized, upscaling 1x1 anime into 2x2 with Diagonal2K does not make sense at all, and is not a good indicator of quality. There is no way the algorithm will recover the 2x2 anime with a single pixel.**

Let's also say that in their world, downscaling is always done using the Nearest-Neighbour algorithm.

Due to the small brains of Pixels, the authors of Diagonal4K do not realize that if the 1x1 image is black, it must be Anime 1, and if it were to be be white instead, Anime 2.

But 4 years prior, another group of smart pixels used the power of machine learning to augment their small brains. Their algorithm sexyCircle2x, a pixel-network, learnt that 1x1 black image is Anime 1, and 1x1 white is Anime 2. It learnt the distribution of Animes, and correctly guesses what anime corresponds to what pixel color.

People were dumbfounded. "Wow! It can basically generate anime!" "Incredible! Details out of thin air!" "Garbage In, Awesomeness out!"

Back to the present, those Pixels dug out sexyCircle2x and begun their comparison. The pixel-network upscales 1x1 -> 2x2 correctly, while Diagonal4K does not. Thus they concluded that Diagonal4K must be inferior.

![Demo 1](results/Demo/1x1-2x2.png?raw=true)

Applying sexyCircle2x to 2x2 anime also yields plausible 4x4 "anime", but they do not and will never know if it is truly anime. However they trust the algorithm enough since it is a pixel-network, and must be smarter than their small Pixel brains.  

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

Some people prefer sharp lines and don't really mind the pastel painting look that Anime4K sometime produces, while some will certainly despise sharp lines and the pastel look. We're not here to judge the individual, so please do not judge others' taste and keep it civil.
