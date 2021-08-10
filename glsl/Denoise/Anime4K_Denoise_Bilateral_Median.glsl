// MIT License

// Copyright (c) 2019-2021 bloc97
// All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//!DESC Anime4K-v3.2-Denoise-Bilateral-Median-Luma
//!HOOK MAIN
//!BIND HOOKED
//!SAVE LINELUMA
//!COMPONENTS 1

float get_luma(vec4 rgba) {
	return dot(vec4(0.299, 0.587, 0.114, 0.0), rgba);
}

vec4 hook() {
    return vec4(get_luma(HOOKED_tex(HOOKED_pos)), 0.0, 0.0, 0.0);
}

//!DESC Anime4K-v3.2-Denoise-Bilateral-Median-Apply
//!HOOK MAIN
//!BIND HOOKED
//!BIND LINELUMA

#define INTENSITY_SIGMA 0.1 //Intensity window size, higher is stronger denoise, must be a positive real number
#define SPATIAL_SIGMA 1.0 //Spatial window size, higher is stronger denoise, must be a positive real number.
#define HISTOGRAM_REGULARIZATION 0.0 //Histogram regularization window size, higher values approximate a bilateral "closest-to-mean" filter.

#define INTENSITY_POWER_CURVE 1.0 //Intensity window power curve. Setting it to 0 will make the intensity window treat all intensities equally, while increasing it will make the window narrower in darker intensities and wider in brighter intensities.

#define KERNELSIZE int(max(int(SPATIAL_SIGMA), 1) * 2 + 1) //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE (int(KERNELSIZE/2)) //Half of the kernel size without remainder. Must be equal to trunc(KERNELSIZE/2).
#define KERNELLEN (KERNELSIZE * KERNELSIZE) //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

#define GETOFFSET(i) vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE)

float gaussian(float x, float s, float m) {
	float scaled = (x - m) / s;
	return exp(-0.5 * scaled * scaled);
}

vec4 getMedian(vec4 v[KERNELLEN], float w[KERNELLEN], float n) {
	
	for (int i=0; i<KERNELLEN; i++) {
		float w_above = 0.0;
		float w_below = 0.0;
		for (int j=0; j<KERNELLEN; j++) {
			if (v[j].x > v[i].x) {
				w_above += w[j];
			} else if (v[j].x < v[i].x) {
				w_below += w[j];
			}
		}
		
		if ((n - w_above) / n >= 0.5 && w_below / n <= 0.5) {
			return v[i];
		}
	}
}

vec4 hook() {
	vec4 histogram_v[KERNELLEN];
	float histogram_l[KERNELLEN];
	float histogram_w[KERNELLEN];
	float n = 0.0;
	
	float vc = LINELUMA_tex(HOOKED_pos).x;
	
	float is = pow(vc + 0.0001, INTENSITY_POWER_CURVE) * INTENSITY_SIGMA;
	float ss = SPATIAL_SIGMA;
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = GETOFFSET(i);
		histogram_v[i] = HOOKED_texOff(ipos);
		histogram_l[i] = LINELUMA_texOff(ipos).x;
		histogram_w[i] = gaussian(histogram_l[i], is, vc) * gaussian(length(ipos), ss, 0.0);
		n += histogram_w[i];
	}
	
	if (HISTOGRAM_REGULARIZATION > 0.0) {
		float histogram_wn[KERNELLEN];
		n = 0.0;
		
		for (int i=0; i<KERNELLEN; i++) {
			histogram_wn[i] = 0.0;
		}
		
		for (int i=0; i<KERNELLEN; i++) {
			histogram_wn[i] += gaussian(0.0, HISTOGRAM_REGULARIZATION, 0.0) * histogram_w[i];
			for (int j=(i+1); j<KERNELLEN; j++) {
				float d = gaussian(histogram_l[j], HISTOGRAM_REGULARIZATION, histogram_l[i]);
				histogram_wn[j] += d * histogram_w[i];
				histogram_wn[i] += d * histogram_w[j];
			}
			n += histogram_wn[i];
		}
	
		return getMedian(histogram_v, histogram_wn, n);
	}
	
	return getMedian(histogram_v, histogram_w, n);
}