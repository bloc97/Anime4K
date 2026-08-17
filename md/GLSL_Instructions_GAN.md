# GAN Shader Instructions (GLSL / MPV) (v4.1)

> **These shaders are experimental and are not part of any release.**
> They are not included in the `Anime4K_v4.0.zip` asset attached to
> [releases](https://github.com/bloc97/Anime4K/releases), and they are not used by any of the
> templates in [`Template/`](Template). To use them you have to take the `.glsl` files directly
> from [`glsl/Upscale/`](../glsl/Upscale) and [`glsl/Restore/`](../glsl/Restore) in this
> repository.
>
> They have known, unfixed quality issues. See [Known issues](#known-issues) before using them.

## What "GAN" means here

The GAN shaders are not a different kind of program from the CNN shaders, and they are not a
large network being run through some runtime. They are the same thing: a very small
convolutional network, compiled ahead of time into plain mpv GLSL with its weights inlined as
constants. Every pass is `Conv 3x3` + `CReLU`, exactly as in the CNN shaders.

The difference is entirely in **how the weights were trained**. The CNN shaders were trained
against a reconstruction ("MSE"-style) loss. The GAN shaders were trained with an additional
adversarial loss, which tends to produce more plausible fine texture and less of the smoothing
that a pure reconstruction loss causes — at the cost of being much harder to train stably. The
artifacts documented below are a consequence of that instability, not of the shader format.

____
## Available shaders

### Upscale

| Shader | Scale | Passes | Size |
| ------ | ----- | ------ | ---- |
| [`Anime4K_Upscale_GAN_x2_S.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x2_S.glsl) | **x2** | 17 | 76K |
| [`Anime4K_Upscale_GAN_x2_M.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x2_M.glsl) | **x2** | 23 | 144K |
| [`Anime4K_Upscale_GAN_x3_L.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x3_L.glsl) | **x3** | 30 | 236K |
| [`Anime4K_Upscale_GAN_x3_VL.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x3_VL.glsl) | **x3** | 47 | 416K |
| [`Anime4K_Upscale_GAN_x4_UL.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x4_UL.glsl) | **x4** | 67 | 684K |
| [`Anime4K_Upscale_GAN_x4_UUL.glsl`](../glsl/Upscale/Anime4K_Upscale_GAN_x4_UUL.glsl) | **x4** | 84 | 1.1M |

### Restore

| Shader | Scale | Passes | Size |
| ------ | ----- | ------ | ---- |
| [`Anime4K_Restore_GAN_UL.glsl`](../glsl/Restore/Anime4K_Restore_GAN_UL.glsl) | x1 | 18 | 240K |
| [`Anime4K_Restore_GAN_UUL.glsl`](../glsl/Restore/Anime4K_Restore_GAN_UUL.glsl) | x1 | 18 | 240K |

Both Restore GAN variants have identical structure and differ only in their weights. They were
trained for **low resolution** sources, which is the case the regular `Restore` shaders are
explicitly not optimized for; `UUL` targets the 360p→4K experiment shown in the README.

____
## The upscalers are fixed-ratio — this changes the composition rules

This is the most important practical difference, and it makes most of the guidance in
[Advanced Usage Instructions](GLSL_Instructions_Advanced.md) not apply.

Every `Upscale_CNN_x2` shader scales by exactly x2, so the standard modes reach a 4x pipeline by
**chaining two of them**. The GAN upscalers do not work that way. Each one performs its whole
ratio internally — `x2`, `x3` or `x4` — in a single file:

```
//!WIDTH conv0ups.w 4 *      # from Anime4K_Upscale_GAN_x4_UL.glsl
```

Consequences:

  - **Use exactly one GAN upscaler.** Do not chain them to reach a higher ratio. Pick the file
    whose ratio matches what you need.
  - **`AutoDownscalePre_x2` / `AutoDownscalePre_x4` have nothing to do.** They exist to downscale
    *between* two upscaling steps. With a single-step upscaler there is no in-between, so leave
    them out.
  - The "add upscale shaders until the pipeline upscales at least 4x" rule from the advanced
    guide is already satisfied by `x4_UL` or `x4_UUL` on their own.

Like the CNN upscalers, the GAN upscalers carry a `//!WHEN` guard and will not run unless the
output is at least 1.2x the source in both dimensions. The Restore GAN shaders have no such
guard and always run.

### Size letters are not comparable to the CNN shaders

`S`/`M`/`L`/`VL`/`UL` rank the GAN shaders against *each other* only. They do not correspond to
the CNN tier of the same letter, and the GAN shaders are considerably more expensive:

| | Passes | Size |
|---|---|---|
| `Upscale_CNN_x2_M` | 9 | 40K |
| `Upscale_GAN_x2_S` | 17 | 76K |

So the *smallest* GAN upscaler already costs roughly twice what the CNN `M` variant does at the
same x2 ratio. Budget accordingly — the framerate targets in the
[advanced guide](GLSL_Instructions_Advanced.md#best-practices) still apply (~41ms for 24fps),
and the mpv profiler (`Shift+I`, then `2`) is still the way to check.

____
## Example configurations

Add these to `input.conf`. The examples use `;` as the shader separator, which is correct on
**Windows**; on **Mac and Linux** use `:` instead.

A 1080p→4K pipeline, replacing the two chained CNN upscalers with one GAN upscaler:

```
CTRL+4 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_VL.glsl;~~/shaders/Anime4K_Upscale_GAN_x2_M.glsl"; show-text "Anime4K: GAN x2 M"
```

A low-resolution source (360p/480p) to 4K, using the Restore GAN in place of the CNN restore:

```
CTRL+5 no-osd change-list glsl-shaders set "~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_GAN_UUL.glsl;~~/shaders/Anime4K_Upscale_GAN_x4_UUL.glsl"; show-text "Anime4K: GAN 360p"
```

`Anime4K_Upscale_GAN_x4_UUL.glsl` is 84 passes and over 1MB of inlined weights. It is intended
as a quality reference for the low-resolution experiment, not as a shader most GPUs will run in
real time.

____
## Known issues

These are unresolved. They are tracked on the maintainer's own
[v4.x roadmap](https://github.com/bloc97/Anime4K/issues/145).

  - **`Upscale_GAN_x2_M` produces visible artifacts** that the other GAN variants do not
    ([#146](https://github.com/bloc97/Anime4K/issues/146)). The maintainer's assessment was that
    the network "didn't converge correctly during training", with smaller single-pixel artifacts
    also visible in the `L` variant. If you see edge artifacts, try `x2_S` instead.
  - **`Restore_GAN_UL` shifts colors**, most visibly on faces and flat background regions;
    `Restore_GAN_UUL` does so less obviously. This is attributed to the discriminator not having
    seen some colors during training.
  - **The Restore GAN shaders can oversharpen.** They work on small patches and cannot tell
    whether blur or grain in a region is a compression artifact or an intentional artistic
    choice, so they may "restore" detail that was never degraded.

Because of these, the shipped templates and the A/B/C modes deliberately use the CNN shaders.
Treat the GAN shaders as something to A/B against your own content rather than as a default.
