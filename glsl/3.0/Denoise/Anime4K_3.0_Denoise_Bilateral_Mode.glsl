//Anime4K v3.0 GLSL

// MIT License

// Copyright (c) 2019-2020 bloc97
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

//!DESC Anime4K-v3.0-Denoise-Bilateral-Mode
//!HOOK NATIVE
//!BIND HOOKED

#define STRENGTH 0.1 //Intensity window size, higher is stronger denoise
#define SPREAD_STRENGTH 1.0 //Spatial window size, higher is stronger denoise
#define MODE_REGULARIZATION 0.196 //Mode regularization window size, higher values approximate a bilateral mean filter.


#define KERNELSIZE 3 //Kernel size, must be an positive odd integer.
#define KERNELHALFSIZE 1 //Half of the kernel size without remainder. Must be equal to floor(KERNELSIZE/2).
#define KERNELLEN 9 //Total area of kernel. Must be equal to KERNELSIZE * KERNELSIZE.

#define GETOFFSET(i) vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE)

float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}


vec4 getMode(vec4 histogram_v[KERNELLEN], float histogram_w[KERNELLEN]) {
	vec4 maxv = vec4(0);
	float maxw = 0;
	
	for (int i=0; i<KERNELLEN; i++) {
		if (histogram_w[i] >= maxw) {
			maxw = histogram_w[i];
			maxv = histogram_v[i];
		}
	}
	
	return maxv;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	vec4 histogram_v[KERNELLEN];
	float histogram_w[KERNELLEN];
	float histogram_wn[KERNELLEN];
	
	float vc = HOOKED_tex(HOOKED_pos).x;
	
	float s = vc * STRENGTH + 0.0001;
	float ss = SPREAD_STRENGTH + 0.0001;
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = GETOFFSET(i);
		histogram_v[i] = HOOKED_tex(HOOKED_pos + ipos * d);
		histogram_w[i] = gaussian(vc - histogram_v[i].x, s, 0) * gaussian(distance(vec2(0), ipos), ss, 0);
		histogram_wn[i] = 0;
	}
	
	for (int i=0; i<KERNELLEN; i++) {
		for (int j=0; j<KERNELLEN; j++) {
			histogram_wn[j] += gaussian(histogram_v[j].x, MODE_REGULARIZATION, histogram_v[i].x) * histogram_w[i];
		}
	}
	
	return vec4(getMode(histogram_v, histogram_wn).x, HOOKED_tex(HOOKED_pos).yz, 0);
}