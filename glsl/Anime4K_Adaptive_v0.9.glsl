// MIT License

// Copyright (c) 2019 bloc97

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


//!HOOK SCALED
//!BIND HOOKED
//!DESC Anime4K-ComputeLuma-v0.9
//!BIND POSTKERNEL
//!SAVE POSTKERNEL

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6;
}

vec4 hook() { //Save lum on POSTKERNEL
	vec4 rgb = HOOKED_tex(HOOKED_pos);
	float lum = getLum(rgb);
    return vec4(lum);
}


//!HOOK SCALED
//!BIND HOOKED
//!DESC Anime4K-ThinLines-v0.9
//!BIND POSTKERNEL
//!BIND NATIVE

#define strength (min((SCALED_size.x) / (NATIVE_size.x) / 6, 1))

vec4 getLargest(vec4 cc, vec4 lightestColor, vec4 a, vec4 b, vec4 c) {
	vec4 newColor = cc * (1 - strength) + ((a + b + c) / 3) * strength;
	if (newColor.a > lightestColor.a) {
		return newColor;
	}
	return lightestColor;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {
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
	
	vec4 lightestColor = cc;

	//Kernel 0 and 4
	float maxDark = max3v(br, b, bl);
	float minLight = min3v(tl, t, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, tl, t, tr);
	} else {
		maxDark = max3v(tl, t, tr);
		minLight = min3v(br, b, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3v(cc, l, b);
	minLight = min3v(r, t, tr);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, t, tr);
	} else {
		maxDark = max3v(cc, r, t);
		minLight = min3v(bl, l, b);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3v(l, tl, bl);
	minLight = min3v(r, br, tr);
	
	if (minLight > cc.a && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, tr);
	} else {
		maxDark = max3v(r, br, tr);
		minLight = min3v(l, tl, bl);
		if (minLight > cc.a && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3v(cc, l, t);
	minLight = min3v(r, br, b);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, b);
	} else {
		maxDark = max3v(cc, r, b);
		minLight = min3v(t, l, tl);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, t, l, tl);
		}
	}
	
	
	return lightestColor;
}


//!HOOK SCALED
//!BIND HOOKED
//!DESC Anime4K-ComputeLuma-v0.9
//!BIND POSTKERNEL
//!SAVE POSTKERNEL

float getLum(vec4 rgb) {
	return (rgb.r + rgb.r + rgb.g + rgb.g + rgb.g + rgb.b) / 6;
}

vec4 hook() { //Save lum on POSTKERNEL
	vec4 rgb = HOOKED_tex(HOOKED_pos);
	float lum = getLum(rgb);
    return vec4(lum);
}


//!HOOK SCALED
//!BIND HOOKED
//!DESC Anime4K-ComputeGradient-v0.9
//!BIND POSTKERNEL
//!SAVE POSTKERNEL

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

vec4 hook() { //Save grad on POSTKERNEL
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
    vec4 cc = getRGBL(HOOKED_pos);
	vec4 t = getRGBL(HOOKED_pos + vec2(0, -d.y));
	vec4 tl = getRGBL(HOOKED_pos + vec2(-d.x, -d.y));
	vec4 tr = getRGBL(HOOKED_pos + vec2(d.x, -d.y));
	
	vec4 l = getRGBL(HOOKED_pos + vec2(-d.x, 0));
	vec4 r = getRGBL(HOOKED_pos + vec2(d.x, 0));
	
	vec4 b = getRGBL(HOOKED_pos + vec2(0, d.y));
	vec4 bl = getRGBL(HOOKED_pos + vec2(-d.x, d.y));
	vec4 br = getRGBL(HOOKED_pos + vec2(d.x, d.y));
	
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-tl.a + tr.a - l.a - l.a + r.a + r.a - bl.a + br.a);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-tl.a - t.a - t.a - tr.a + bl.a + b.a + b.a + br.a);
	
	//Computes the luminance's gradient and saves it in the unused alpha channel
	return vec4(1 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1));
}



//!HOOK SCALED
//!BIND HOOKED
//!DESC Anime4K-Refine-v0.9
//!BIND POSTKERNEL
//!BIND NATIVE

#define strength (min((SCALED_size.x) / (NATIVE_size.x) / 2, 1))

vec4 getAverage(vec4 cc, vec4 a, vec4 b, vec4 c) {
	return cc * (1 - strength) + ((a + b + c) / 3) * strength;
}

vec4 getRGBL(vec2 pos) {
    return vec4(HOOKED_tex(pos).rgb, POSTKERNEL_tex(pos).x);
}

float min3v(vec4 a, vec4 b, vec4 c) {
	return min(min(a.a, b.a), c.a);
}
float max3v(vec4 a, vec4 b, vec4 c) {
	return max(max(a.a, b.a), c.a);
}


vec4 hook()  {
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
