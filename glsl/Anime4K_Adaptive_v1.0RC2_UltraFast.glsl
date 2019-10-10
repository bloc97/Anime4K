//Anime4K GLSL v1.0 Release Candidate 2

// MIT License

// Copyright (c) 2019 bloc97, DextroseRe

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

//!DESC Anime4K-ComputeGradientX-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!SAVE LUMAD
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMA_tex(HOOKED_pos + vec2(-d.x, 0)).x;
    float c = LUMA_tex(HOOKED_pos).x;
	float r = LUMA_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-l + r);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (l + c + c + r);
	
	//Computes the luminance's gradient
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-ComputeGradientY-v1.0RC2
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAD
//!SAVE LUMAD
//!COMPONENTS 1

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	float tx = LUMAD_tex(HOOKED_pos + vec2(0, -d.y)).x;
    float cx = LUMAD_tex(HOOKED_pos).x;
	float bx = LUMAD_tex(HOOKED_pos + vec2(0, d.y)).x;
	
	
	float ty = LUMAD_tex(HOOKED_pos + vec2(0, -d.y)).y;
    //float cy = LUMAD_tex(HOOKED_pos).y;
	float by = LUMAD_tex(HOOKED_pos + vec2(0, d.y)).y;
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (tx + cx + cx + bx);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-ty + by);
	
	//Computes the luminance's gradient
	return vec4(1 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1), 0, 0, 0);
}


//!DESC Anime4K-ComputeLineGaussianX-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAD
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian5(vec2 pos, vec2 d) {
	float g = LUMAD_tex(pos - (d * 2)).x * 0.187691;
	g = g + LUMAD_tex(pos - d).x * 0.206038;
	g = g + LUMAD_tex(pos).x * 0.212543;
	g = g + LUMAD_tex(pos + d).x * 0.206038;
	g = g + LUMAD_tex(pos + (d * 2)).x * 0.187691;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian5(HOOKED_pos, vec2(HOOKED_pt.x, 0));
    return vec4(g, 0, 0, 0);
}



//!DESC Anime4K-ComputeLineGaussianY-v1.0RC2
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!HOOK LUMA
//!BIND HOOKED
//!BIND LUMAG
//!BIND LUMAD
//!SAVE LUMAG
//!COMPONENTS 1

float lumGaussian5(vec2 pos, vec2 d) {
	float g = LUMAG_tex(pos - (d * 2)).x * 0.187691;
	g = g + LUMAG_tex(pos - d).x * 0.206038;
	g = g + LUMAG_tex(pos).x * 0.212543;
	g = g + LUMAG_tex(pos + d).x * 0.206038;
	g = g + LUMAG_tex(pos + (d * 2)).x * 0.187691;
	
	return clamp(g, 0, 1); //Clamp for sanity check
}

vec4 hook() {
	float g = lumGaussian5(HOOKED_pos, vec2(0, HOOKED_pt.y));
    return vec4(1 - g, 0, 0, 0);
}

//!DESC Anime4K-Refine-v1.0RC2
//!HOOK SCALED
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMAG

#define LINE_DETECT_THRESHOLD 0.4
#define MAX_STRENGTH 0.6

#define strength (min((SCALED_size.x) / (LUMA_size.x), 1))
#define lineprob (LUMAG_tex(HOOKED_pos).x)

vec4 getAverage(vec4 cc, vec4 a, vec4 b, vec4 c) {
	float realstrength = clamp(strength, 0, MAX_STRENGTH);
	return cc * (1 - realstrength) + ((a + b + c) / 3) * realstrength;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, LUMAD_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {

	if (lineprob < LINE_DETECT_THRESHOLD) {
		return HOOKED_tex(HOOKED_pos);
	}

	vec2 d = HOOKED_pt;
	
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		return getAverage(cc, tl, t, tr);
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
			return getAverage(cc, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
		return getAverage(cc, r, t, tr);
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
			return getAverage(cc, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		return getAverage(cc, r, br, tr);
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
			return getAverage(cc, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
		return getAverage(cc, r, br, b);
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
			return getAverage(cc, t, l, tl);
		}
	}
	
	
	return cc;
}
