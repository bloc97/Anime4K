// $MinimumShaderProfile: ps_2_a

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

sampler s0 : register(s0);
float4 p0 :  register(c0);
float4 p1 :  register(c1);

#define width   (p0[0])
#define height  (p0[1])
#define counter (p0[2])
#define clock   (p0[3])
#define dx (p1[0])
#define dy (p1[1])
#define PI acos(-1)

#define strength 0.3

float min3(float4 a, float4 b, float4 c) {
	return min(min(a[3], b[3]), c[3]);
}
float max3(float4 a, float4 b, float4 c) {
	return max(max(a[3], b[3]), c[3]);
}

float4 getLargest(float4 cc, float4 lightestColor, float4 a, float4 b, float4 c) {
	float4 newColor = cc * (1 - strength) + ((a + b + c) / 3) * strength;
	if (newColor[3] > lightestColor[3]) {
		return newColor;
	}
	return lightestColor;
}

float4 main(float2 tex : TEXCOORD0) : COLOR {
	
	float4 cc = tex2D(s0, tex); //Current Color
	
	float4 t = tex2D(s0, tex + float2(0, -dy));
	float4 tl = tex2D(s0, tex + float2(-dx, -dy));
	float4 tr = tex2D(s0, tex + float2(dx, -dy));
	
	float4 l = tex2D(s0, tex + float2(-dx, 0));
	float4 r = tex2D(s0, tex + float2(dx, 0));
	
	float4 b = tex2D(s0, tex + float2(0, dy));
	float4 bl = tex2D(s0, tex + float2(-dx, dy));
	float4 br = tex2D(s0, tex + float2(dx, dy));
	
	
	float4 lightestColor = cc;

	//Kernel 0 and 4
	float maxDark = max3(br, b, bl);
	float minLight = min3(tl, t, tr);
	
	if (minLight > cc[3] && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, tl, t, tr);
	} else {
		maxDark = max3(tl, t, tr);
		minLight = min3(br, b, bl);
		if (minLight > cc[3] && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, br, b, bl);
		}
	}
	
	//Kernel 1 and 5
	maxDark = max3(cc, l, b);
	minLight = min3(r, t, tr);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, t, tr);
	} else {
		maxDark = max3(cc, r, t);
		minLight = min3(bl, l, b);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, bl, l, b);
		}
	}
	
	//Kernel 2 and 6
	maxDark = max3(l, tl, bl);
	minLight = min3(r, br, tr);
	
	if (minLight > cc[3] && minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, tr);
	} else {
		maxDark = max3(r, br, tr);
		minLight = min3(l, tl, bl);
		if (minLight > cc[3] && minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, l, tl, bl);
		}
	}
	
	//Kernel 3 and 7
	maxDark = max3(cc, l, t);
	minLight = min3(r, br, b);
	
	if (minLight > maxDark) {
		lightestColor = getLargest(cc, lightestColor, r, br, b);
	} else {
		maxDark = max3(cc, r, b);
		minLight = min3(t, l, tl);
		if (minLight > maxDark) {
			lightestColor = getLargest(cc, lightestColor, t, l, tl);
		}
	}
	
	
	return lightestColor;
}
