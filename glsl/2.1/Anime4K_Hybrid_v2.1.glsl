//Anime4K Hybrid GLSL v2.1

// MIT License

// Copyright (c) 2019-2020 bloc97, DextroseRe
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


//!DESC Anime4K-Hybrid-Chroma-Upscale-v2.1
//!HOOK CHROMA
//!BIND HOOKED
//!BIND LUMA
//!WHEN CHROMA.w LUMA.w <
//!WIDTH CHROMA.w 2 *
//!HEIGHT CHROMA.h 2 *

/* ---------------------- BILATERAL FILTERING SETTINGS ---------------------- */

#define STRENGTH 0.1
#define SPREAD_STRENGTH 2.0

/* --- MOST OF THE OTHER SETTINGS CAN BE FOUND AT THE END --- */

#define KERNELSIZE 3
#define KERNELHALFSIZE 1
#define KERNELLEN 9


float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float vc = LUMA_tex(HOOKED_pos).x;
	
	float s = vc * STRENGTH + 0.0001;
	float ss = SPREAD_STRENGTH + 0.0001;
	
	vec4 valsum = vec4(0);
	float normsum = 0.000001; //Avoid divide by zero
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE);
		float l = LUMA_tex(HOOKED_pos + ipos * d).x;
		float w = gaussian(vc - l, s, 0) * gaussian(distance(vec2(0), ipos), ss, 0);
		valsum += HOOKED_tex(HOOKED_pos + ipos * d) * w;
		normsum += w;
	}
	
	return valsum / normsum;
}



//!DESC Anime4K-Hybrid-Luma-Denoise-v2.1
//!HOOK LUMA
//!BIND HOOKED

/* ---------------------- BILATERAL MODE FILTERING SETTINGS ---------------------- */

#define STRENGTH 0.1
#define SPREAD_STRENGTH 2.0
#define MODE_REGULARIZATION 50.0

/* --- MOST OF THE OTHER SETTINGS CAN BE FOUND AT THE END --- */

#define KERNELSIZE 3
#define KERNELHALFSIZE 1
#define KERNELLEN 9

#define GETOFFSET(i) vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE)


float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}


vec4 getMode(vec4 histogram_v[KERNELLEN], float histogram_w[KERNELLEN]) {
	vec4 maxv = vec4(0);
	float maxw = 0;
	
	for (int i=0; i<KERNELLEN; i++) {
		if (histogram_w[i] > maxw) {
			maxw = histogram_w[i];
			maxv = histogram_v[i];
		}
	}
	
	return maxv;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	float sharpval = clamp(HOOKED_size.x / 1920, 0, 1);
	
	
	vec4 histogram_v[KERNELLEN];
	float histogram_w[KERNELLEN];
	float histogram_wn[KERNELLEN];
	
	float vc = HOOKED_tex(HOOKED_pos).x;
	
	float s = vc * STRENGTH + 0.0001;
	float ss = SPREAD_STRENGTH * sharpval + 0.0001;
	
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = GETOFFSET(i);
		histogram_v[i] = HOOKED_tex(HOOKED_pos + ipos * d);
		histogram_w[i] = gaussian(vc - histogram_v[i].x, s, 0) * gaussian(distance(vec2(0), ipos), ss, 0);
		histogram_wn[i] = 0;
	}
	
	float sr = MODE_REGULARIZATION / 255.0;
	
	
	for (int i=0; i<KERNELLEN; i++) {
		for (int j=0; j<KERNELLEN; j++) {
			histogram_wn[j] += gaussian(histogram_v[j].x, sr, histogram_v[i].x) * histogram_w[i];
		}
	}
	
	
	return vec4(getMode(histogram_v, histogram_wn).x, 0, 0, 0);
}

/* ---------------------- x2 PRESCALER ---------------------- */

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x1-v2.1
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!SAVE LUMAN0
//!COMPONENTS 4


vec4 hook() {
	vec2 dp = HOOKED_pt;
	float a = HOOKED_tex(HOOKED_pos + vec2(-dp.x, -dp.y)).x;
	float b = HOOKED_tex(HOOKED_pos + vec2(-dp.x, 0)).x;
	float c = HOOKED_tex(HOOKED_pos + vec2(-dp.x, dp.y)).x;
	float d = HOOKED_tex(HOOKED_pos + vec2(0, -dp.y)).x;
	float e = HOOKED_tex(HOOKED_pos + vec2(0, 0)).x;
	float f = HOOKED_tex(HOOKED_pos + vec2(0, dp.y)).x;
	float g = HOOKED_tex(HOOKED_pos + vec2(dp.x, -dp.y)).x;
	float h = HOOKED_tex(HOOKED_pos + vec2(dp.x, 0)).x;
	float i = HOOKED_tex(HOOKED_pos + vec2(dp.x, dp.y)).x;

	float s = 0.06518857*a + -0.0118667185*b + -0.07614037*c + -0.46956885*d + 0.2812869*e + 0.4135128*f + -0.117597*g + -0.43488324*h + 0.33814532*i;
	float o = s+0.018250784;
	s = 0.004705962*a + 0.064553976*b + -0.07471142*c + -0.12856083*d + 0.15492548*e + 0.7035231*f + 0.16384916*g + -0.8741586*h + -0.012426951*i;
	float p = s+0.0018347593;
	s = -0.002186087*a + 0.08980697*b + -0.075706676*c + 0.21820599*d + -1.4773877*e + 0.39514637*f + -0.049297944*g + 0.3549184*h + 0.5490852*i;
	float q = s+0.0019366593;
	s = -0.0019400899*a + 0.02402473*b + -0.07429219*c + 0.16930206*d + -0.2798244*e + 0.08784747*f + -0.018798571*g + 0.039233245*h + 0.053139925*i;
	float r = s+0.0028748403;
	return vec4(o, p, q, r);
}


//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAN0
//!SAVE LUMAN0
//!COMPONENTS 4

#define L_tex LUMAN0_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);
	
	float s = -0.078850485*a.x + 0.008778143*b.x + 0.09409134*c.x + 0.17980288*d.x + -0.13836896*e.x + 0.041511726*f.x + 0.111073226*g.x + 0.24465907*h.x + -0.2613636*i.x;
	float t = 0.04978624*a.y + -0.043356195*b.y + -0.08137738*c.y + -0.028674556*d.y + -0.0042590224*e.y + -0.06741321*f.y + 0.04029311*g.y + -0.069561794*h.y + 0.067619696*i.y;
	float u = -0.0061189956*a.z + 0.051833455*b.z + -0.042832106*c.z + 0.26535267*d.z + 0.36819696*e.z + 0.03438765*f.z + 0.22989632*g.z + -0.487135*h.z + 0.15665813*i.z;
	float v = -0.13148193*a.w + -0.12638648*b.w + 0.03605439*c.w + 0.0974745*d.w + -0.10980721*e.w + -0.21564873*f.w + 0.34306243*g.w + 0.69539255*h.w + -0.03078458*i.w;
	float w = 0.1898412*na.x + 0.05917433*nb.x + -0.15381081*nc.x + -0.15773135*nd.x + 0.29555428*ne.x + 0.096428104*nf.x + 0.090633914*ng.x + -0.31970337*nh.x + 0.18953186*ni.x;
	float x = -0.26538706*na.y + 0.13089244*nb.y + 0.16604574*nc.y + -0.5723114*nd.y + -0.16346131*ne.y + -0.014951056*nf.y + 0.09785819*ng.y + -0.017660556*nh.y + -0.09167879*ni.y;
	float y = 0.009693713*na.z + 0.010756051*nb.z + 0.017140212*nc.z + -0.533805*nd.z + -0.5435189*ne.z + -0.064089194*nf.z + -0.31916615*ng.z + 0.5331712*nh.z + -0.13033615*ni.z;
	float z = 0.35296175*na.w + 0.25480655*nb.w + 0.035030134*nc.w + 0.15741913*nd.w + 0.060176335*ne.w + 0.05028458*nf.w + -0.12958519*ng.w + 0.028535347*nh.w + 0.15037805*ni.w;
	float o = s+t+u+v+w+x+y+z+-0.00046534537;
	s = -0.10862142*a.x + 0.23951219*b.x + 0.2839895*c.x + -0.05217377*d.x + -0.40397635*e.x + 0.049454965*f.x + 0.052400503*g.x + 0.118543915*h.x + 0.06852737*i.x;
	t = 0.4241042*a.y + -0.12584575*b.y + -0.102870226*c.y + 0.28188303*d.y + 0.49546632*e.y + 0.117695816*f.y + -0.08839783*g.y + -0.14269592*h.y + -0.03292176*i.y;
	u = 0.007181128*a.z + -0.40109172*b.z + -0.24221501*c.z + -0.06402019*d.z + 0.60842943*e.z + -0.10117115*f.z + -0.14966127*g.z + -0.14179903*h.z + -0.03214188*i.z;
	v = 0.049681976*a.w + -0.18726541*b.w + -0.13386123*c.w + -0.43944734*d.w + -0.7732026*e.w + -0.19998854*f.w + 0.0016352575*g.w + -0.15936574*h.w + 0.11486744*i.w;
	w = 0.034904238*na.x + -0.3936257*nb.x + -0.3924321*nc.x + 0.13237436*nd.x + 0.41971052*ne.x + -0.17690897*nf.x + -0.104041904*ng.x + -0.10885315*nh.x + -0.07546228*ni.x;
	x = 0.19798991*na.y + 0.4755196*nb.y + 0.1685174*nc.y + -0.056067895*nd.y + -0.3281361*ne.y + -0.060975373*nf.y + 0.15498285*ng.y + 0.23860317*nh.y + 0.078440316*ni.y;
	y = 0.22032484*na.z + 0.45825586*nb.z + 0.24928105*nc.z + 0.0740922*nd.z + -0.83567154*ne.z + 0.1469111*nf.z + 0.1061305*ng.z + 0.054175954*nh.z + 0.023593672*ni.z;
	z = 0.02721891*na.w + -0.40433592*nb.w + -0.20104738*nc.w + -0.090347335*nd.w + 0.32021475*ne.w + -0.2523179*nf.w + 0.18747182*ng.w + -0.042044852*nh.w + -0.28740782*ni.w;
	float p = s+t+u+v+w+x+y+z+-0.0048994347;
	s = 0.03506187*a.x + -0.19858655*b.x + 0.12969843*c.x + -0.10771284*d.x + -0.09441664*e.x + 0.45179757*f.x + 0.0192464*g.x + 0.08926137*h.x + -0.06842973*i.x;
	t = -0.06226018*a.y + -0.032557767*b.y + -0.16808012*c.y + -0.05757842*d.y + 0.16631629*e.y + -0.34194738*f.y + 0.005270219*g.y + 0.02339046*h.y + 0.079298474*i.y;
	u = 0.125203*a.z + 0.11796023*b.z + 0.13894552*c.z + 0.122039534*d.z + 0.093743816*e.z + -0.36432076*f.z + 0.024767118*g.z + 0.05475351*h.z + 0.025071215*i.z;
	v = -0.18731116*a.w + 0.12831227*b.w + -0.17373508*c.w + -0.3514785*d.w + -0.6449611*e.w + -0.13499886*f.w + 0.010178755*g.w + -0.49852073*h.w + 0.0992664*i.w;
	w = -0.047569968*na.x + 0.107844934*nb.x + -0.34977105*nc.x + 0.123500414*nd.x + 0.055304836*ne.x + -0.48315105*nf.x + 0.0026811515*ng.x + -0.08091307*nh.x + 0.0610684*ni.x;
	x = 0.15171343*na.y + 0.57235277*nb.y + 0.255104*nc.y + 0.031828027*nd.y + -0.07049035*ne.y + 0.40309858*nf.y + -0.027855068*ng.y + 0.033779*nh.y + -0.08337315*ni.y;
	y = -0.05789993*na.z + 0.15511025*nb.z + -0.18869878*nc.z + -0.124532856*nd.z + -0.1330072*ne.z + 0.37427673*nf.z + -0.041740254*ng.z + -0.08676065*nh.z + -0.007624626*ni.z;
	z = -0.040559176*na.w + -0.035778075*nb.w + 0.071473464*nc.w + 0.23743495*nd.w + -0.32282174*ne.w + 0.105933495*nf.w + 0.04571244*ng.w + 0.5551143*nh.w + -0.093935035*ni.w;
	float q = s+t+u+v+w+x+y+z+-0.0033313776;
	s = 0.075606935*a.x + 0.12968872*b.x + -0.17267832*c.x + -0.017534962*d.x + -0.21092632*e.x + 0.6039601*f.x + 0.0006366408*g.x + -0.3433534*h.x + 0.4382395*i.x;
	t = -0.31210127*a.y + -0.24801569*b.y + 0.14311266*c.y + 0.266147*d.y + 0.20114625*e.y + -0.40220937*f.y + -0.2854783*g.y + -0.13323757*h.y + -0.1416884*i.y;
	u = -0.08245917*a.z + -0.04328727*b.z + 0.011549445*c.z + 0.03169343*d.z + 0.30852476*e.z + -0.14224593*f.z + -0.2026233*g.z + 0.49105433*h.z + -0.27598178*i.z;
	v = -0.03321247*a.w + -0.18208264*b.w + 0.0034254584*c.w + 0.093554296*d.w + -0.8836113*e.w + -0.21680102*f.w + -0.27222317*g.w + -1.0443908*h.w + -0.5674947*i.w;
	w = -0.01619753*na.x + -0.12963338*nb.x + 0.17563225*nc.x + 0.004585129*nd.x + -0.3158967*ne.x + -0.872042*nf.x + -0.03607397*ng.x + 0.21791828*nh.x + -0.39065713*ni.x;
	x = 0.20459439*na.y + 0.14653577*nb.y + -0.20970102*nc.y + -0.22334248*nd.y + -0.1049179*ne.y + 0.4063564*nf.y + -0.004260764*ng.y + 0.0077243396*nh.y + 0.19195783*ni.y;
	y = 0.14778891*na.z + 0.08660305*nb.z + 0.069295146*nc.z + 0.085611*nd.z + 0.37579855*ne.z + 0.29285663*nf.z + 0.17906432*ng.z + -0.37996793*nh.z + 0.23048665*ni.z;
	z = -0.30503413*na.w + -0.008632153*nb.w + -0.03432621*nc.w + -0.6234461*nd.w + 0.2332829*ne.w + -0.15835847*nf.w + 0.17630823*ng.w + -0.004949296*nh.w + 0.10454355*ni.w;
	float r = s+t+u+v+w+x+y+z+-0.006210959;
	return vec4(o, p, q, r);
}

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAN0
//!SAVE LUMAN0
//!COMPONENTS 4

#define L_tex LUMAN0_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);
	
	float s = -0.076375276*a.x + -0.16192478*b.x + -0.3435801*c.x + -0.102615885*d.x + -0.34291154*e.x + -0.3715771*f.x + -0.040065594*g.x + -0.031282134*h.x + -0.14007968*i.x;
	float t = 0.0672231*a.y + -0.04764941*b.y + 0.098419875*c.y + 0.25985655*d.y + -0.38082376*e.y + 0.49276826*f.y + 0.08231613*g.y + 0.110389665*h.y + 0.12316233*i.y;
	float u = 0.062234916*a.z + -0.08981316*b.z + 0.035350677*c.z + 0.3298534*d.z + -0.53112257*e.z + 0.07900975*f.z + -0.5878461*g.z + 0.3894751*h.z + 0.14318523*i.z;
	float v = -0.067861155*a.w + 0.5679219*b.w + -0.20925492*c.w + -0.10364462*d.w + 0.04910827*e.w + 0.05719115*f.w + -0.030506052*g.w + 0.19142777*h.w + 0.029463196*i.w;
	float w = -0.06478752*na.x + -0.35909376*nb.x + -0.049066383*nc.x + -0.06414304*nd.x + -0.13888775*ne.x + -0.059843887*nf.x + -0.076657444*ng.x + -0.20727734*nh.x + 0.037852272*ni.x;
	float x = 0.0111666415*na.y + 0.11577456*nb.y + -0.07413471*nc.y + -0.020178368*nd.y + 0.16065867*ne.y + 0.114819236*nf.y + 0.102682814*ng.y + -0.026029458*nh.y + 0.09669771*ni.y;
	float y = -0.07489544*na.z + -0.16045223*nb.z + -0.09865632*nc.z + 0.033090383*nd.z + -0.31668448*ne.z + -0.10984895*nf.z + 0.072489046*ng.z + -0.082067624*nh.z + -0.021043802*ni.z;
	float z = 0.15612242*na.w + 0.25616717*nb.w + 0.15281045*nc.w + 0.12763329*nd.w + 0.44922253*ne.w + 0.069874264*nf.w + 0.049967453*ng.w + -0.016834527*nh.w + 0.076151155*ni.w;
	float o = s+t+u+v+w+x+y+z+0.004368779;
	s = -0.047799945*a.x + -0.11515582*b.x + -0.40791252*c.x + 0.018251693*d.x + 0.14576633*e.x + -0.11556127*f.x + -0.03873749*g.x + 0.060810573*h.x + -0.07200133*i.x;
	t = 0.16543166*a.y + 0.011941809*b.y + 0.047324877*c.y + 0.04958495*d.y + -0.1651876*e.y + 0.43078738*f.y + -0.02519319*g.y + 0.20227197*h.y + 0.025999023*i.y;
	u = 0.033441387*a.z + 0.016795462*b.z + 0.057281017*c.z + 1.5043137*d.z + 0.31060156*e.z + 0.07275219*f.z + -1.1843078*g.z + -0.6761157*h.z + 0.0029731095*i.z;
	v = 0.4444829*a.w + -0.42409083*b.w + -0.26248664*c.w + -0.01794927*d.w + -0.018550927*e.w + 0.017927665*f.w + -0.032345075*g.w + 0.20667751*h.w + 0.0010150699*i.w;
	w = 0.099501655*na.x + -0.28775364*nb.x + 0.32228288*nc.x + -0.00772114*nd.x + -0.23449002*ne.x + -0.09296215*nf.x + -0.054157354*ng.x + -0.27360436*nh.x + -0.03951609*ni.x;
	x = -0.028245373*na.y + -0.121913314*nb.y + 0.07654564*nc.y + -0.049665563*nd.y + 0.7794895*ne.y + -0.1505789*nf.y + -0.03943592*ng.y + -0.34458607*nh.y + 0.084370665*ni.y;
	y = -0.08433866*na.z + 0.051757183*nb.z + -0.020638762*nc.z + -0.33128256*nd.z + -0.650777*ne.z + -0.11522274*nf.z + 0.26052502*ng.z + 0.34106*nh.z + 0.014920869*ni.z;
	z = 0.04507247*na.w + -0.103196636*nb.w + 0.13806596*nc.w + 0.08855919*nd.w + 0.19656824*ne.w + 0.09237863*nf.w + 0.046644468*ng.w + -0.04016784*nh.w + 0.04972401*ni.w;
	float p = s+t+u+v+w+x+y+z+0.0046657724;
	s = -0.056063537*a.x + 0.31379348*b.x + 0.08083433*c.x + -0.07988621*d.x + -0.28616846*e.x + -0.08654294*f.x + 0.113976635*g.x + 0.06516338*h.x + 0.018438872*i.x;
	t = -0.11620833*a.y + 0.21208929*b.y + -0.11346605*c.y + -0.067703396*d.y + -0.43201342*e.y + -0.5345245*f.y + 0.07686346*g.y + 0.6436457*h.y + 0.26798856*i.y;
	u = -0.06619781*a.z + -0.10010958*b.z + -0.07167439*c.z + -0.13878949*d.z + 0.0575283*e.z + -0.01815303*f.z + -0.076679595*g.z + 0.25056645*h.z + -0.030564506*i.z;
	v = 0.12286161*a.w + -0.31997183*b.w + 0.4049721*c.w + -0.014453491*d.w + -0.12128047*e.w + -0.20630093*f.w + 0.064631835*g.w + 0.06505699*h.w + -0.04836569*i.w;
	w = 0.030468628*na.x + -0.9605534*nb.x + 0.31949607*nc.x + -0.028109128*nd.x + 0.17402208*ne.x + 0.40973142*nf.x + -0.030756505*ng.x + -0.06860691*nh.x + 0.078861415*ni.x;
	x = -0.018858679*na.y + 0.01308505*nb.y + 0.0344467*nc.y + -0.16346104*nd.y + 0.16348976*ne.y + -0.08839573*nf.y + 0.015383088*ng.y + -0.14421648*nh.y + -0.12157047*ni.y;
	y = -0.2401164*na.z + 0.12919497*nb.z + -0.026884526*nc.z + 0.011329444*nd.z + -0.11406845*ne.z + -0.029941153*nf.z + 0.2084126*ng.z + -0.15498434*nh.z + 0.02121424*ni.z;
	z = 0.11573471*na.w + -0.03703832*nb.w + 0.019915955*nc.w + -0.08166001*nd.w + 0.09089532*ne.w + 0.016573701*nf.w + -0.093835354*ng.w + -0.03263581*nh.w + 0.07502409*ni.w;
	float q = s+t+u+v+w+x+y+z+0.0028720675;
	s = -0.09465834*a.x + -0.07953802*b.x + -0.17295821*c.x + -0.08021209*d.x + -0.1958469*e.x + -0.24971394*f.x + -0.12543827*g.x + -0.034206524*h.x + -0.042293545*i.x;
	t = 0.017930178*a.y + -0.022108268*b.y + 0.09107495*c.y + 0.2796261*d.y + 0.26334488*e.y + 0.3403926*f.y + 0.0052007795*g.y + 0.00029919678*h.y + 0.2550915*i.y;
	u = 0.026925193*a.z + -0.04275811*b.z + -0.0047453125*c.z + -0.11763906*d.z + -0.169145*e.z + 0.07742117*f.z + 0.07685529*g.z + -0.040824294*h.z + 0.07746296*i.z;
	v = -0.345795*a.w + 0.43350878*b.w + -0.3304852*c.w + -0.06460919*d.w + 0.029501494*e.w + 0.088321574*f.w + -0.03855111*g.w + 0.14674814*h.w + 0.08218873*i.w;
	w = -0.051307168*na.x + -0.19062272*nb.x + -0.385643*nc.x + -0.059386916*nd.x + -0.32816103*ne.x + -0.039611306*nf.x + 0.02802185*ng.x + -0.12741719*nh.x + -0.03717902*ni.x;
	x = 0.047177624*na.y + 0.09041485*nb.y + -0.051103875*nc.y + 0.1100884*nd.y + -0.19083166*ne.y + 0.2213158*nf.y + 0.07442079*ng.y + 0.3593766*nh.y + -0.24011746*ni.y;
	y = -0.076973915*na.z + -0.19071229*nb.z + -0.055816684*nc.z + -0.11463048*nd.z + -0.07194704*ne.z + -0.14436463*nf.z + -0.35647246*ng.z + 0.14373139*nh.z + 0.08208823*ni.z;
	z = 0.16350232*na.w + 0.24001768*nb.w + 0.1772575*nc.w + 0.08607296*nd.w + -0.08327933*ne.w + 0.33616975*nf.w + 0.09244664*ng.w + -0.026265353*nh.w + 0.04598941*ni.w;
	float r = s+t+u+v+w+x+y+z+0.00076911174;
	
	return vec4(o, p, q, r);
}

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!BIND LUMAN0
//!SAVE LUMAN0
//!COMPONENTS 4

#define L_tex LUMAN0_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);

	float s = 0.07986198*a.x + 0.11342182*b.x + -0.0030975514*c.x + -0.19796455*d.x + 0.013101459*e.x + -0.04200098*f.x + 0.017225444*g.x + -0.0014372912*h.x + 0.008370759*i.x;
	float t = 0.014841376*a.y + -0.041046176*b.y + 0.03788454*c.y + 0.054837294*d.y + 0.13426651*e.y + -0.0080451695*f.y + -0.029857455*g.y + -0.012871764*h.y + -0.03441029*i.y;
	float u = 0.06245403*a.z + -0.012831481*b.z + 0.061856076*c.z + 0.064062476*d.z + -0.066138364*e.z + -0.0026366066*f.z + 0.011879*g.z + -0.011122004*h.z + 0.0017384114*i.z;
	float v = -0.05975413*a.w + -0.17485596*b.w + 0.025911752*c.w + 0.118029304*d.w + 0.04408629*e.w + 0.008907612*f.w + 0.01642477*g.w + -0.0092969695*h.w + -0.000769117*i.w;
	float w = 0.051101964*na.x + -0.18510687*nb.x + 0.028513199*nc.x + 0.14805903*nd.x + -0.20142192*ne.x + 0.056813676*nf.x + 0.0017134928*ng.x + 0.054168973*nh.x + -0.021714801*ni.x;
	float x = -0.020875074*na.y + 0.0048777545*nb.y + -0.06269994*nc.y + -0.03472058*nd.y + 0.048265714*ne.y + 0.0035236937*nf.y + 0.005227413*ng.y + -0.027124068*nh.y + 0.018154047*ni.y;
	float y = -0.01159801*na.z + 0.033479054*nb.z + -0.038438387*nc.z + -0.052317906*nd.z + -0.17036878*ne.z + 0.030379958*nf.z + 0.00838193*ng.z + 0.056501616*nh.z + 0.012519291*ni.z;
	float z = -0.09538882*na.w + 0.26771805*nb.w + -0.043541078*nc.w + -0.032106128*nd.w + 0.0934046*ne.w + -0.01805561*nf.w + -0.04645964*ng.w + -0.0036514637*nh.w + 0.008913154*ni.w;
	float o = s+t+u+v+w+x+y+z+-0.00044684345;
	s = -0.011545017*a.x + -0.014384322*b.x + 0.017081236*c.x + -0.08324924*d.x + 0.21428387*e.x + -0.013944155*f.x + -0.02362489*g.x + -0.048795808*h.x + -0.028883195*i.x;
	t = 0.018386116*a.y + -0.026253551*b.y + 0.0118806455*c.y + 0.037654113*d.y + -0.06835073*e.y + 0.032385923*f.y + 0.0026887117*g.y + 0.10095452*h.y + 0.0022080252*i.y;
	u = 0.007332604*a.z + -0.093728594*b.z + -0.0092954915*c.z + 0.10711502*d.z + 0.067041464*e.z + 0.029980924*f.z + 0.018776521*g.z + -0.010771681*h.z + 0.010082272*i.z;
	v = 0.08082619*a.w + -0.049494464*b.w + -0.002847315*c.w + -0.032200564*d.w + -0.106779605*e.w + -0.00017057461*f.w + 0.046220686*g.w + -0.010086206*h.w + 0.014189474*i.w;
	w = 0.01763419*na.x + -0.07704289*nb.x + 0.014544706*nc.x + 0.26217622*nd.x + -0.27793178*ne.x + 0.049043182*nf.x + -0.032387003*ng.x + -0.00079001323*nh.x + 0.021493236*ni.x;
	x = -0.006099039*na.y + 0.07619911*nb.y + -0.004682871*nc.y + -0.039725974*nd.y + -0.0956842*ne.y + -0.047193985*nf.y + 0.012972832*ng.y + -0.029965244*nh.y + 0.01117153*ni.y;
	y = -0.0047858395*na.z + 0.009432101*nb.z + -0.00970283*nc.z + -0.050967053*nd.z + 0.0416414*ne.z + 0.006567818*nf.z + -0.019049477*ng.z + -0.055457648*nh.z + -0.0084786*ni.z;
	z = -0.020594368*na.w + 0.119097516*nb.w + -0.026706293*nc.w + -0.26399305*nd.w + 0.24297448*ne.w + -0.02357126*nf.w + 0.055582974*ng.w + 0.026176132*nh.w + -0.0049385377*ni.w;
	float p = s+t+u+v+w+x+y+z+-0.0005098261;
	s = 0.007989906*a.x + 0.16948476*b.x + -0.020900989*c.x + 0.047029756*d.x + -0.3106828*e.x + 0.044901974*f.x + -0.022907237*g.x + 0.05710629*h.x + 0.052065603*i.x;
	t = -0.017990815*a.y + 0.017270472*b.y + 0.010282366*c.y + -0.011884632*d.y + 0.23191552*e.y + -0.043236367*f.y + 0.0016425329*g.y + -0.055511087*h.y + -0.026324613*i.y;
	u = 0.0019120462*a.z + 0.08208013*b.z + 0.034132402*c.z + -0.018370727*d.z + 0.07797786*e.z + -0.060526185*f.z + -0.0018448521*g.z + -0.00033979217*h.z + 0.00335727*i.z;
	v = -0.07492346*a.w + -0.12594028*b.w + 0.014072716*c.w + 0.08883091*d.w + 0.10869792*e.w + -0.008024153*f.w + -0.0085559655*g.w + -0.026130557*h.w + -0.038244307*i.w;
	w = -0.043121733*na.x + 0.03908438*nb.x + -0.04203372*nc.x + -0.06984061*nd.x + 0.22654058*ne.x + -0.0677497*nf.x + 0.023323534*ng.x + -0.007752401*nh.x + -0.04204327*ni.x;
	x = 0.0063822027*na.y + -0.06692327*nb.y + -0.024546446*nc.y + 0.011857771*nd.y + -0.10809846*ne.y + 0.10203533*nf.y + 0.00044697413*ng.y + 0.00013562286*nh.y + 0.0015593648*ni.y;
	y = -0.0045949556*na.z + 0.0020794072*nb.z + -0.01384561*nc.z + -0.028907942*nd.z + -0.1312241*ne.z + -0.021974247*nf.z + 0.016818015*ng.z + 0.048700895*nh.z + 0.013344767*ni.z;
	z = 0.09069866*na.w + -0.07002809*nb.w + 0.024288913*nc.w + 0.03665063*nd.w + -0.04747613*ne.w + 0.025434596*nf.w + -0.040272254*ng.w + -0.007083052*nh.w + 0.033061597*ni.w;
	float q = s+t+u+v+w+x+y+z+-5.6695724e-05;
	s = -0.030995423*a.x + 0.016910668*b.x + 0.016467795*c.x + 0.0036362244*d.x + 0.06715467*e.x + 0.034928087*f.x + 0.00294668*g.x + -0.08859904*h.x + 0.019238671*i.x;
	t = -0.0014795385*a.y + 0.007169236*b.y + -0.003910267*c.y + -0.013714315*d.y + 0.047127932*e.y + -0.032306857*f.y + 0.009032661*g.y + 0.07451486*h.y + 0.011209902*i.y;
	u = -0.028070455*a.z + -0.056255367*b.z + -0.01941142*c.z + -0.014563226*d.z + 0.23374811*e.z + -0.005298336*f.z + -0.0015773315*g.z + 0.010755963*h.z + 0.010304858*i.z;
	v = 0.010758766*a.w + -0.0016641767*b.w + -0.0072932625*c.w + 0.04894674*d.w + -0.13094418*e.w + -0.013401469*f.w + 0.011060128*g.w + 0.0017654237*h.w + -0.007799787*i.w;
	w = -0.0068978816*na.x + -0.011936246*nb.x + -0.04713535*nc.x + -0.02783707*nd.x + 0.24141848*ne.x + -0.07389717*nf.x + -0.013193195*ng.x + 0.0112745045*nh.x + -0.01864954*ni.x;
	x = 0.0038846259*na.y + 0.033482198*nb.y + 0.02776248*nc.y + 0.02706673*nd.y + -0.22279294*ne.y + 0.009941126*nf.y + 0.009544681*ng.y + -0.025446441*nh.y + 0.011225284*ni.y;
	y = 0.002453317*na.z + -0.0026645362*nb.z + -0.0037308321*nc.z + -0.026038155*nd.z + 0.027270524*ne.z + 0.009217475*nf.z + -0.015977709*ng.z + -0.023630898*nh.z + -0.03964392*ni.z;
	z = 0.0229635*na.w + 0.0007620235*nb.w + 0.03816787*nc.w + 0.012008527*nd.w + -0.16997801*ne.w + 0.048762847*nf.w + 0.0011025064*ng.w + 0.064071506*nh.w + 0.0049902974*ni.w;
	float r = s+t+u+v+w+x+y+z+-0.00035512418;
	
	return vec4(o, p, q, r);
}

//!HOOK LUMA
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!DESC Anime4K-Hybrid-ML-PixelShuffle-v2.1
//!BIND LUMAN0
//!SAVE LUMANE
//!COMPONENTS 2

vec4 hook() {
	vec2 f = fract(LUMAN0_pos * LUMAN0_size);
	ivec2 i = ivec2(f * vec2(2));
	vec4 residual = LUMAN0_tex((vec2(0.5) - f) * LUMAN0_pt + LUMAN0_pos);
	return vec4(residual[i.y * 2 + i.x], 0, 0, 0);
}

//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.400 > OUTPUT.h LUMA.h / 1.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!DESC Anime4K-Hybrid-ML-Upscale(x2)-v2.1
//!BIND LUMANE


vec4 hook() {
	return vec4(LUMANE_tex(HOOKED_pos).x + HOOKED_tex(HOOKED_pos).x, HOOKED_tex(HOOKED_pos).yz, 0);
}

/* ---------------------- x4 PRESCALER ---------------------- */


//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!DESC Anime4K-Hybrid-Chroma-Upscale(x2)-v2.1

#define STRENGTH 0.1
#define SPREAD_STRENGTH 2.0

/* --- MOST OF THE OTHER SETTINGS CAN BE FOUND AT THE END --- */

#define KERNELSIZE 3
#define KERNELHALFSIZE 1
#define KERNELLEN 9


float gaussian(float x, float s, float m) {
	return (1 / (s * sqrt(2 * 3.14159))) * exp(-0.5 * pow(abs(x - m) / s, 2.0));
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	vec4 vc = HOOKED_tex(HOOKED_pos);
	
	float s = vc.x * STRENGTH + 0.0001;
	float ss = SPREAD_STRENGTH + 0.0001;
	
	vec4 valsum = vec4(0);
	float normsum = 0.000001; //Avoid divide by zero
	
	for (int i=0; i<KERNELLEN; i++) {
		vec2 ipos = vec2((i % KERNELSIZE) - KERNELHALFSIZE, (i / KERNELSIZE) - KERNELHALFSIZE);
		vec4 l = HOOKED_tex(HOOKED_pos + ipos * d);
		float w = gaussian(vc.x - l.x, s, 0) * gaussian(distance(vec2(0), ipos), ss, 0);
		valsum += l * w;
		normsum += w;
	}
	
	return vec4(vc.x, (valsum / normsum).yz, 0);
}

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x1-v2.1
//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!SAVE LUMAN1
//!COMPONENTS 4


vec4 hook() {
	vec2 dp = HOOKED_pt;
	float a = HOOKED_tex(HOOKED_pos + vec2(-dp.x, -dp.y)).x;
	float b = HOOKED_tex(HOOKED_pos + vec2(-dp.x, 0)).x;
	float c = HOOKED_tex(HOOKED_pos + vec2(-dp.x, dp.y)).x;
	float d = HOOKED_tex(HOOKED_pos + vec2(0, -dp.y)).x;
	float e = HOOKED_tex(HOOKED_pos + vec2(0, 0)).x;
	float f = HOOKED_tex(HOOKED_pos + vec2(0, dp.y)).x;
	float g = HOOKED_tex(HOOKED_pos + vec2(dp.x, -dp.y)).x;
	float h = HOOKED_tex(HOOKED_pos + vec2(dp.x, 0)).x;
	float i = HOOKED_tex(HOOKED_pos + vec2(dp.x, dp.y)).x;

	float s = 0.06518857*a + -0.0118667185*b + -0.07614037*c + -0.46956885*d + 0.2812869*e + 0.4135128*f + -0.117597*g + -0.43488324*h + 0.33814532*i;
	float o = s+0.018250784;
	s = 0.004705962*a + 0.064553976*b + -0.07471142*c + -0.12856083*d + 0.15492548*e + 0.7035231*f + 0.16384916*g + -0.8741586*h + -0.012426951*i;
	float p = s+0.0018347593;
	s = -0.002186087*a + 0.08980697*b + -0.075706676*c + 0.21820599*d + -1.4773877*e + 0.39514637*f + -0.049297944*g + 0.3549184*h + 0.5490852*i;
	float q = s+0.0019366593;
	s = -0.0019400899*a + 0.02402473*b + -0.07429219*c + 0.16930206*d + -0.2798244*e + 0.08784747*f + -0.018798571*g + 0.039233245*h + 0.053139925*i;
	float r = s+0.0028748403;
	return vec4(o, p, q, r);
}


//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!BIND LUMAN1
//!SAVE LUMAN1
//!COMPONENTS 4

#define L_tex LUMAN1_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);
	
	float s = -0.078850485*a.x + 0.008778143*b.x + 0.09409134*c.x + 0.17980288*d.x + -0.13836896*e.x + 0.041511726*f.x + 0.111073226*g.x + 0.24465907*h.x + -0.2613636*i.x;
	float t = 0.04978624*a.y + -0.043356195*b.y + -0.08137738*c.y + -0.028674556*d.y + -0.0042590224*e.y + -0.06741321*f.y + 0.04029311*g.y + -0.069561794*h.y + 0.067619696*i.y;
	float u = -0.0061189956*a.z + 0.051833455*b.z + -0.042832106*c.z + 0.26535267*d.z + 0.36819696*e.z + 0.03438765*f.z + 0.22989632*g.z + -0.487135*h.z + 0.15665813*i.z;
	float v = -0.13148193*a.w + -0.12638648*b.w + 0.03605439*c.w + 0.0974745*d.w + -0.10980721*e.w + -0.21564873*f.w + 0.34306243*g.w + 0.69539255*h.w + -0.03078458*i.w;
	float w = 0.1898412*na.x + 0.05917433*nb.x + -0.15381081*nc.x + -0.15773135*nd.x + 0.29555428*ne.x + 0.096428104*nf.x + 0.090633914*ng.x + -0.31970337*nh.x + 0.18953186*ni.x;
	float x = -0.26538706*na.y + 0.13089244*nb.y + 0.16604574*nc.y + -0.5723114*nd.y + -0.16346131*ne.y + -0.014951056*nf.y + 0.09785819*ng.y + -0.017660556*nh.y + -0.09167879*ni.y;
	float y = 0.009693713*na.z + 0.010756051*nb.z + 0.017140212*nc.z + -0.533805*nd.z + -0.5435189*ne.z + -0.064089194*nf.z + -0.31916615*ng.z + 0.5331712*nh.z + -0.13033615*ni.z;
	float z = 0.35296175*na.w + 0.25480655*nb.w + 0.035030134*nc.w + 0.15741913*nd.w + 0.060176335*ne.w + 0.05028458*nf.w + -0.12958519*ng.w + 0.028535347*nh.w + 0.15037805*ni.w;
	float o = s+t+u+v+w+x+y+z+-0.00046534537;
	s = -0.10862142*a.x + 0.23951219*b.x + 0.2839895*c.x + -0.05217377*d.x + -0.40397635*e.x + 0.049454965*f.x + 0.052400503*g.x + 0.118543915*h.x + 0.06852737*i.x;
	t = 0.4241042*a.y + -0.12584575*b.y + -0.102870226*c.y + 0.28188303*d.y + 0.49546632*e.y + 0.117695816*f.y + -0.08839783*g.y + -0.14269592*h.y + -0.03292176*i.y;
	u = 0.007181128*a.z + -0.40109172*b.z + -0.24221501*c.z + -0.06402019*d.z + 0.60842943*e.z + -0.10117115*f.z + -0.14966127*g.z + -0.14179903*h.z + -0.03214188*i.z;
	v = 0.049681976*a.w + -0.18726541*b.w + -0.13386123*c.w + -0.43944734*d.w + -0.7732026*e.w + -0.19998854*f.w + 0.0016352575*g.w + -0.15936574*h.w + 0.11486744*i.w;
	w = 0.034904238*na.x + -0.3936257*nb.x + -0.3924321*nc.x + 0.13237436*nd.x + 0.41971052*ne.x + -0.17690897*nf.x + -0.104041904*ng.x + -0.10885315*nh.x + -0.07546228*ni.x;
	x = 0.19798991*na.y + 0.4755196*nb.y + 0.1685174*nc.y + -0.056067895*nd.y + -0.3281361*ne.y + -0.060975373*nf.y + 0.15498285*ng.y + 0.23860317*nh.y + 0.078440316*ni.y;
	y = 0.22032484*na.z + 0.45825586*nb.z + 0.24928105*nc.z + 0.0740922*nd.z + -0.83567154*ne.z + 0.1469111*nf.z + 0.1061305*ng.z + 0.054175954*nh.z + 0.023593672*ni.z;
	z = 0.02721891*na.w + -0.40433592*nb.w + -0.20104738*nc.w + -0.090347335*nd.w + 0.32021475*ne.w + -0.2523179*nf.w + 0.18747182*ng.w + -0.042044852*nh.w + -0.28740782*ni.w;
	float p = s+t+u+v+w+x+y+z+-0.0048994347;
	s = 0.03506187*a.x + -0.19858655*b.x + 0.12969843*c.x + -0.10771284*d.x + -0.09441664*e.x + 0.45179757*f.x + 0.0192464*g.x + 0.08926137*h.x + -0.06842973*i.x;
	t = -0.06226018*a.y + -0.032557767*b.y + -0.16808012*c.y + -0.05757842*d.y + 0.16631629*e.y + -0.34194738*f.y + 0.005270219*g.y + 0.02339046*h.y + 0.079298474*i.y;
	u = 0.125203*a.z + 0.11796023*b.z + 0.13894552*c.z + 0.122039534*d.z + 0.093743816*e.z + -0.36432076*f.z + 0.024767118*g.z + 0.05475351*h.z + 0.025071215*i.z;
	v = -0.18731116*a.w + 0.12831227*b.w + -0.17373508*c.w + -0.3514785*d.w + -0.6449611*e.w + -0.13499886*f.w + 0.010178755*g.w + -0.49852073*h.w + 0.0992664*i.w;
	w = -0.047569968*na.x + 0.107844934*nb.x + -0.34977105*nc.x + 0.123500414*nd.x + 0.055304836*ne.x + -0.48315105*nf.x + 0.0026811515*ng.x + -0.08091307*nh.x + 0.0610684*ni.x;
	x = 0.15171343*na.y + 0.57235277*nb.y + 0.255104*nc.y + 0.031828027*nd.y + -0.07049035*ne.y + 0.40309858*nf.y + -0.027855068*ng.y + 0.033779*nh.y + -0.08337315*ni.y;
	y = -0.05789993*na.z + 0.15511025*nb.z + -0.18869878*nc.z + -0.124532856*nd.z + -0.1330072*ne.z + 0.37427673*nf.z + -0.041740254*ng.z + -0.08676065*nh.z + -0.007624626*ni.z;
	z = -0.040559176*na.w + -0.035778075*nb.w + 0.071473464*nc.w + 0.23743495*nd.w + -0.32282174*ne.w + 0.105933495*nf.w + 0.04571244*ng.w + 0.5551143*nh.w + -0.093935035*ni.w;
	float q = s+t+u+v+w+x+y+z+-0.0033313776;
	s = 0.075606935*a.x + 0.12968872*b.x + -0.17267832*c.x + -0.017534962*d.x + -0.21092632*e.x + 0.6039601*f.x + 0.0006366408*g.x + -0.3433534*h.x + 0.4382395*i.x;
	t = -0.31210127*a.y + -0.24801569*b.y + 0.14311266*c.y + 0.266147*d.y + 0.20114625*e.y + -0.40220937*f.y + -0.2854783*g.y + -0.13323757*h.y + -0.1416884*i.y;
	u = -0.08245917*a.z + -0.04328727*b.z + 0.011549445*c.z + 0.03169343*d.z + 0.30852476*e.z + -0.14224593*f.z + -0.2026233*g.z + 0.49105433*h.z + -0.27598178*i.z;
	v = -0.03321247*a.w + -0.18208264*b.w + 0.0034254584*c.w + 0.093554296*d.w + -0.8836113*e.w + -0.21680102*f.w + -0.27222317*g.w + -1.0443908*h.w + -0.5674947*i.w;
	w = -0.01619753*na.x + -0.12963338*nb.x + 0.17563225*nc.x + 0.004585129*nd.x + -0.3158967*ne.x + -0.872042*nf.x + -0.03607397*ng.x + 0.21791828*nh.x + -0.39065713*ni.x;
	x = 0.20459439*na.y + 0.14653577*nb.y + -0.20970102*nc.y + -0.22334248*nd.y + -0.1049179*ne.y + 0.4063564*nf.y + -0.004260764*ng.y + 0.0077243396*nh.y + 0.19195783*ni.y;
	y = 0.14778891*na.z + 0.08660305*nb.z + 0.069295146*nc.z + 0.085611*nd.z + 0.37579855*ne.z + 0.29285663*nf.z + 0.17906432*ng.z + -0.37996793*nh.z + 0.23048665*ni.z;
	z = -0.30503413*na.w + -0.008632153*nb.w + -0.03432621*nc.w + -0.6234461*nd.w + 0.2332829*ne.w + -0.15835847*nf.w + 0.17630823*ng.w + -0.004949296*nh.w + 0.10454355*ni.w;
	float r = s+t+u+v+w+x+y+z+-0.006210959;
	return vec4(o, p, q, r);
}

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!BIND LUMAN1
//!SAVE LUMAN1
//!COMPONENTS 4

#define L_tex LUMAN1_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);
	
	float s = -0.076375276*a.x + -0.16192478*b.x + -0.3435801*c.x + -0.102615885*d.x + -0.34291154*e.x + -0.3715771*f.x + -0.040065594*g.x + -0.031282134*h.x + -0.14007968*i.x;
	float t = 0.0672231*a.y + -0.04764941*b.y + 0.098419875*c.y + 0.25985655*d.y + -0.38082376*e.y + 0.49276826*f.y + 0.08231613*g.y + 0.110389665*h.y + 0.12316233*i.y;
	float u = 0.062234916*a.z + -0.08981316*b.z + 0.035350677*c.z + 0.3298534*d.z + -0.53112257*e.z + 0.07900975*f.z + -0.5878461*g.z + 0.3894751*h.z + 0.14318523*i.z;
	float v = -0.067861155*a.w + 0.5679219*b.w + -0.20925492*c.w + -0.10364462*d.w + 0.04910827*e.w + 0.05719115*f.w + -0.030506052*g.w + 0.19142777*h.w + 0.029463196*i.w;
	float w = -0.06478752*na.x + -0.35909376*nb.x + -0.049066383*nc.x + -0.06414304*nd.x + -0.13888775*ne.x + -0.059843887*nf.x + -0.076657444*ng.x + -0.20727734*nh.x + 0.037852272*ni.x;
	float x = 0.0111666415*na.y + 0.11577456*nb.y + -0.07413471*nc.y + -0.020178368*nd.y + 0.16065867*ne.y + 0.114819236*nf.y + 0.102682814*ng.y + -0.026029458*nh.y + 0.09669771*ni.y;
	float y = -0.07489544*na.z + -0.16045223*nb.z + -0.09865632*nc.z + 0.033090383*nd.z + -0.31668448*ne.z + -0.10984895*nf.z + 0.072489046*ng.z + -0.082067624*nh.z + -0.021043802*ni.z;
	float z = 0.15612242*na.w + 0.25616717*nb.w + 0.15281045*nc.w + 0.12763329*nd.w + 0.44922253*ne.w + 0.069874264*nf.w + 0.049967453*ng.w + -0.016834527*nh.w + 0.076151155*ni.w;
	float o = s+t+u+v+w+x+y+z+0.004368779;
	s = -0.047799945*a.x + -0.11515582*b.x + -0.40791252*c.x + 0.018251693*d.x + 0.14576633*e.x + -0.11556127*f.x + -0.03873749*g.x + 0.060810573*h.x + -0.07200133*i.x;
	t = 0.16543166*a.y + 0.011941809*b.y + 0.047324877*c.y + 0.04958495*d.y + -0.1651876*e.y + 0.43078738*f.y + -0.02519319*g.y + 0.20227197*h.y + 0.025999023*i.y;
	u = 0.033441387*a.z + 0.016795462*b.z + 0.057281017*c.z + 1.5043137*d.z + 0.31060156*e.z + 0.07275219*f.z + -1.1843078*g.z + -0.6761157*h.z + 0.0029731095*i.z;
	v = 0.4444829*a.w + -0.42409083*b.w + -0.26248664*c.w + -0.01794927*d.w + -0.018550927*e.w + 0.017927665*f.w + -0.032345075*g.w + 0.20667751*h.w + 0.0010150699*i.w;
	w = 0.099501655*na.x + -0.28775364*nb.x + 0.32228288*nc.x + -0.00772114*nd.x + -0.23449002*ne.x + -0.09296215*nf.x + -0.054157354*ng.x + -0.27360436*nh.x + -0.03951609*ni.x;
	x = -0.028245373*na.y + -0.121913314*nb.y + 0.07654564*nc.y + -0.049665563*nd.y + 0.7794895*ne.y + -0.1505789*nf.y + -0.03943592*ng.y + -0.34458607*nh.y + 0.084370665*ni.y;
	y = -0.08433866*na.z + 0.051757183*nb.z + -0.020638762*nc.z + -0.33128256*nd.z + -0.650777*ne.z + -0.11522274*nf.z + 0.26052502*ng.z + 0.34106*nh.z + 0.014920869*ni.z;
	z = 0.04507247*na.w + -0.103196636*nb.w + 0.13806596*nc.w + 0.08855919*nd.w + 0.19656824*ne.w + 0.09237863*nf.w + 0.046644468*ng.w + -0.04016784*nh.w + 0.04972401*ni.w;
	float p = s+t+u+v+w+x+y+z+0.0046657724;
	s = -0.056063537*a.x + 0.31379348*b.x + 0.08083433*c.x + -0.07988621*d.x + -0.28616846*e.x + -0.08654294*f.x + 0.113976635*g.x + 0.06516338*h.x + 0.018438872*i.x;
	t = -0.11620833*a.y + 0.21208929*b.y + -0.11346605*c.y + -0.067703396*d.y + -0.43201342*e.y + -0.5345245*f.y + 0.07686346*g.y + 0.6436457*h.y + 0.26798856*i.y;
	u = -0.06619781*a.z + -0.10010958*b.z + -0.07167439*c.z + -0.13878949*d.z + 0.0575283*e.z + -0.01815303*f.z + -0.076679595*g.z + 0.25056645*h.z + -0.030564506*i.z;
	v = 0.12286161*a.w + -0.31997183*b.w + 0.4049721*c.w + -0.014453491*d.w + -0.12128047*e.w + -0.20630093*f.w + 0.064631835*g.w + 0.06505699*h.w + -0.04836569*i.w;
	w = 0.030468628*na.x + -0.9605534*nb.x + 0.31949607*nc.x + -0.028109128*nd.x + 0.17402208*ne.x + 0.40973142*nf.x + -0.030756505*ng.x + -0.06860691*nh.x + 0.078861415*ni.x;
	x = -0.018858679*na.y + 0.01308505*nb.y + 0.0344467*nc.y + -0.16346104*nd.y + 0.16348976*ne.y + -0.08839573*nf.y + 0.015383088*ng.y + -0.14421648*nh.y + -0.12157047*ni.y;
	y = -0.2401164*na.z + 0.12919497*nb.z + -0.026884526*nc.z + 0.011329444*nd.z + -0.11406845*ne.z + -0.029941153*nf.z + 0.2084126*ng.z + -0.15498434*nh.z + 0.02121424*ni.z;
	z = 0.11573471*na.w + -0.03703832*nb.w + 0.019915955*nc.w + -0.08166001*nd.w + 0.09089532*ne.w + 0.016573701*nf.w + -0.093835354*ng.w + -0.03263581*nh.w + 0.07502409*ni.w;
	float q = s+t+u+v+w+x+y+z+0.0028720675;
	s = -0.09465834*a.x + -0.07953802*b.x + -0.17295821*c.x + -0.08021209*d.x + -0.1958469*e.x + -0.24971394*f.x + -0.12543827*g.x + -0.034206524*h.x + -0.042293545*i.x;
	t = 0.017930178*a.y + -0.022108268*b.y + 0.09107495*c.y + 0.2796261*d.y + 0.26334488*e.y + 0.3403926*f.y + 0.0052007795*g.y + 0.00029919678*h.y + 0.2550915*i.y;
	u = 0.026925193*a.z + -0.04275811*b.z + -0.0047453125*c.z + -0.11763906*d.z + -0.169145*e.z + 0.07742117*f.z + 0.07685529*g.z + -0.040824294*h.z + 0.07746296*i.z;
	v = -0.345795*a.w + 0.43350878*b.w + -0.3304852*c.w + -0.06460919*d.w + 0.029501494*e.w + 0.088321574*f.w + -0.03855111*g.w + 0.14674814*h.w + 0.08218873*i.w;
	w = -0.051307168*na.x + -0.19062272*nb.x + -0.385643*nc.x + -0.059386916*nd.x + -0.32816103*ne.x + -0.039611306*nf.x + 0.02802185*ng.x + -0.12741719*nh.x + -0.03717902*ni.x;
	x = 0.047177624*na.y + 0.09041485*nb.y + -0.051103875*nc.y + 0.1100884*nd.y + -0.19083166*ne.y + 0.2213158*nf.y + 0.07442079*ng.y + 0.3593766*nh.y + -0.24011746*ni.y;
	y = -0.076973915*na.z + -0.19071229*nb.z + -0.055816684*nc.z + -0.11463048*nd.z + -0.07194704*ne.z + -0.14436463*nf.z + -0.35647246*ng.z + 0.14373139*nh.z + 0.08208823*ni.z;
	z = 0.16350232*na.w + 0.24001768*nb.w + 0.1772575*nc.w + 0.08607296*nd.w + -0.08327933*ne.w + 0.33616975*nf.w + 0.09244664*ng.w + -0.026265353*nh.w + 0.04598941*ni.w;
	float r = s+t+u+v+w+x+y+z+0.00076911174;
	
	return vec4(o, p, q, r);
}

//!DESC Anime4K-Hybrid-ML-Conv-4x3x3x8-v2.1
//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h 2 *
//!BIND LUMAN1
//!SAVE LUMAN1
//!COMPONENTS 4

#define L_tex LUMAN1_tex

vec4 hook() {
	vec2 dp = HOOKED_pt;
	vec4 a = L_tex(HOOKED_pos + vec2(-dp.x, -dp.y));
	vec4 b = L_tex(HOOKED_pos + vec2(-dp.x, 0));
	vec4 c = L_tex(HOOKED_pos + vec2(-dp.x, dp.y));
	vec4 d = L_tex(HOOKED_pos + vec2(0, -dp.y));
	vec4 e = L_tex(HOOKED_pos + vec2(0, 0));
	vec4 f = L_tex(HOOKED_pos + vec2(0, dp.y));
	vec4 g = L_tex(HOOKED_pos + vec2(dp.x, -dp.y));
	vec4 h = L_tex(HOOKED_pos + vec2(dp.x, 0));
	vec4 i = L_tex(HOOKED_pos + vec2(dp.x, dp.y));
	
	vec4 na = -min(a, 0);
	vec4 nb = -min(b, 0);
	vec4 nc = -min(c, 0);
	vec4 nd = -min(d, 0);
	vec4 ne = -min(e, 0);
	vec4 nf = -min(f, 0);
	vec4 ng = -min(g, 0);
	vec4 nh = -min(h, 0);
	vec4 ni = -min(i, 0);
	
	a = max(a, 0);
	b = max(b, 0);
	c = max(c, 0);
	d = max(d, 0);
	e = max(e, 0);
	f = max(f, 0);
	g = max(g, 0);
	h = max(h, 0);
	i = max(i, 0);

	float s = 0.07986198*a.x + 0.11342182*b.x + -0.0030975514*c.x + -0.19796455*d.x + 0.013101459*e.x + -0.04200098*f.x + 0.017225444*g.x + -0.0014372912*h.x + 0.008370759*i.x;
	float t = 0.014841376*a.y + -0.041046176*b.y + 0.03788454*c.y + 0.054837294*d.y + 0.13426651*e.y + -0.0080451695*f.y + -0.029857455*g.y + -0.012871764*h.y + -0.03441029*i.y;
	float u = 0.06245403*a.z + -0.012831481*b.z + 0.061856076*c.z + 0.064062476*d.z + -0.066138364*e.z + -0.0026366066*f.z + 0.011879*g.z + -0.011122004*h.z + 0.0017384114*i.z;
	float v = -0.05975413*a.w + -0.17485596*b.w + 0.025911752*c.w + 0.118029304*d.w + 0.04408629*e.w + 0.008907612*f.w + 0.01642477*g.w + -0.0092969695*h.w + -0.000769117*i.w;
	float w = 0.051101964*na.x + -0.18510687*nb.x + 0.028513199*nc.x + 0.14805903*nd.x + -0.20142192*ne.x + 0.056813676*nf.x + 0.0017134928*ng.x + 0.054168973*nh.x + -0.021714801*ni.x;
	float x = -0.020875074*na.y + 0.0048777545*nb.y + -0.06269994*nc.y + -0.03472058*nd.y + 0.048265714*ne.y + 0.0035236937*nf.y + 0.005227413*ng.y + -0.027124068*nh.y + 0.018154047*ni.y;
	float y = -0.01159801*na.z + 0.033479054*nb.z + -0.038438387*nc.z + -0.052317906*nd.z + -0.17036878*ne.z + 0.030379958*nf.z + 0.00838193*ng.z + 0.056501616*nh.z + 0.012519291*ni.z;
	float z = -0.09538882*na.w + 0.26771805*nb.w + -0.043541078*nc.w + -0.032106128*nd.w + 0.0934046*ne.w + -0.01805561*nf.w + -0.04645964*ng.w + -0.0036514637*nh.w + 0.008913154*ni.w;
	float o = s+t+u+v+w+x+y+z+-0.00044684345;
	s = -0.011545017*a.x + -0.014384322*b.x + 0.017081236*c.x + -0.08324924*d.x + 0.21428387*e.x + -0.013944155*f.x + -0.02362489*g.x + -0.048795808*h.x + -0.028883195*i.x;
	t = 0.018386116*a.y + -0.026253551*b.y + 0.0118806455*c.y + 0.037654113*d.y + -0.06835073*e.y + 0.032385923*f.y + 0.0026887117*g.y + 0.10095452*h.y + 0.0022080252*i.y;
	u = 0.007332604*a.z + -0.093728594*b.z + -0.0092954915*c.z + 0.10711502*d.z + 0.067041464*e.z + 0.029980924*f.z + 0.018776521*g.z + -0.010771681*h.z + 0.010082272*i.z;
	v = 0.08082619*a.w + -0.049494464*b.w + -0.002847315*c.w + -0.032200564*d.w + -0.106779605*e.w + -0.00017057461*f.w + 0.046220686*g.w + -0.010086206*h.w + 0.014189474*i.w;
	w = 0.01763419*na.x + -0.07704289*nb.x + 0.014544706*nc.x + 0.26217622*nd.x + -0.27793178*ne.x + 0.049043182*nf.x + -0.032387003*ng.x + -0.00079001323*nh.x + 0.021493236*ni.x;
	x = -0.006099039*na.y + 0.07619911*nb.y + -0.004682871*nc.y + -0.039725974*nd.y + -0.0956842*ne.y + -0.047193985*nf.y + 0.012972832*ng.y + -0.029965244*nh.y + 0.01117153*ni.y;
	y = -0.0047858395*na.z + 0.009432101*nb.z + -0.00970283*nc.z + -0.050967053*nd.z + 0.0416414*ne.z + 0.006567818*nf.z + -0.019049477*ng.z + -0.055457648*nh.z + -0.0084786*ni.z;
	z = -0.020594368*na.w + 0.119097516*nb.w + -0.026706293*nc.w + -0.26399305*nd.w + 0.24297448*ne.w + -0.02357126*nf.w + 0.055582974*ng.w + 0.026176132*nh.w + -0.0049385377*ni.w;
	float p = s+t+u+v+w+x+y+z+-0.0005098261;
	s = 0.007989906*a.x + 0.16948476*b.x + -0.020900989*c.x + 0.047029756*d.x + -0.3106828*e.x + 0.044901974*f.x + -0.022907237*g.x + 0.05710629*h.x + 0.052065603*i.x;
	t = -0.017990815*a.y + 0.017270472*b.y + 0.010282366*c.y + -0.011884632*d.y + 0.23191552*e.y + -0.043236367*f.y + 0.0016425329*g.y + -0.055511087*h.y + -0.026324613*i.y;
	u = 0.0019120462*a.z + 0.08208013*b.z + 0.034132402*c.z + -0.018370727*d.z + 0.07797786*e.z + -0.060526185*f.z + -0.0018448521*g.z + -0.00033979217*h.z + 0.00335727*i.z;
	v = -0.07492346*a.w + -0.12594028*b.w + 0.014072716*c.w + 0.08883091*d.w + 0.10869792*e.w + -0.008024153*f.w + -0.0085559655*g.w + -0.026130557*h.w + -0.038244307*i.w;
	w = -0.043121733*na.x + 0.03908438*nb.x + -0.04203372*nc.x + -0.06984061*nd.x + 0.22654058*ne.x + -0.0677497*nf.x + 0.023323534*ng.x + -0.007752401*nh.x + -0.04204327*ni.x;
	x = 0.0063822027*na.y + -0.06692327*nb.y + -0.024546446*nc.y + 0.011857771*nd.y + -0.10809846*ne.y + 0.10203533*nf.y + 0.00044697413*ng.y + 0.00013562286*nh.y + 0.0015593648*ni.y;
	y = -0.0045949556*na.z + 0.0020794072*nb.z + -0.01384561*nc.z + -0.028907942*nd.z + -0.1312241*ne.z + -0.021974247*nf.z + 0.016818015*ng.z + 0.048700895*nh.z + 0.013344767*ni.z;
	z = 0.09069866*na.w + -0.07002809*nb.w + 0.024288913*nc.w + 0.03665063*nd.w + -0.04747613*ne.w + 0.025434596*nf.w + -0.040272254*ng.w + -0.007083052*nh.w + 0.033061597*ni.w;
	float q = s+t+u+v+w+x+y+z+-5.6695724e-05;
	s = -0.030995423*a.x + 0.016910668*b.x + 0.016467795*c.x + 0.0036362244*d.x + 0.06715467*e.x + 0.034928087*f.x + 0.00294668*g.x + -0.08859904*h.x + 0.019238671*i.x;
	t = -0.0014795385*a.y + 0.007169236*b.y + -0.003910267*c.y + -0.013714315*d.y + 0.047127932*e.y + -0.032306857*f.y + 0.009032661*g.y + 0.07451486*h.y + 0.011209902*i.y;
	u = -0.028070455*a.z + -0.056255367*b.z + -0.01941142*c.z + -0.014563226*d.z + 0.23374811*e.z + -0.005298336*f.z + -0.0015773315*g.z + 0.010755963*h.z + 0.010304858*i.z;
	v = 0.010758766*a.w + -0.0016641767*b.w + -0.0072932625*c.w + 0.04894674*d.w + -0.13094418*e.w + -0.013401469*f.w + 0.011060128*g.w + 0.0017654237*h.w + -0.007799787*i.w;
	w = -0.0068978816*na.x + -0.011936246*nb.x + -0.04713535*nc.x + -0.02783707*nd.x + 0.24141848*ne.x + -0.07389717*nf.x + -0.013193195*ng.x + 0.0112745045*nh.x + -0.01864954*ni.x;
	x = 0.0038846259*na.y + 0.033482198*nb.y + 0.02776248*nc.y + 0.02706673*nd.y + -0.22279294*ne.y + 0.009941126*nf.y + 0.009544681*ng.y + -0.025446441*nh.y + 0.011225284*ni.y;
	y = 0.002453317*na.z + -0.0026645362*nb.z + -0.0037308321*nc.z + -0.026038155*nd.z + 0.027270524*ne.z + 0.009217475*nf.z + -0.015977709*ng.z + -0.023630898*nh.z + -0.03964392*ni.z;
	z = 0.0229635*na.w + 0.0007620235*nb.w + 0.03816787*nc.w + 0.012008527*nd.w + -0.16997801*ne.w + 0.048762847*nf.w + 0.0011025064*ng.w + 0.064071506*nh.w + 0.0049902974*ni.w;
	float r = s+t+u+v+w+x+y+z+-0.00035512418;
	
	return vec4(o, p, q, r);
}

//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 4 *
//!HEIGHT LUMA.h 4 *
//!DESC Anime4K-Hybrid-ML-PixelShuffle-v2.1
//!BIND LUMAN1
//!BIND LUMANE
//!SAVE LUMANE
//!COMPONENTS 2

vec4 hook() {
	vec2 f = fract(LUMAN1_pos * LUMAN1_size);
	ivec2 i = ivec2(f * vec2(2));
	vec4 residual = LUMAN1_tex((vec2(0.5) - f) * LUMAN1_pt + LUMAN1_pos);
	return vec4(LUMANE_tex(LUMANE_pos).x, residual[i.y * 2 + i.x], 0, 0);
}


//!HOOK NATIVE
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 2.400 > OUTPUT.h LUMA.h / 2.400 > *
//!WIDTH LUMA.w 4 *
//!HEIGHT LUMA.h 4 *
//!DESC Anime4K-Hybrid-ML-Upscale(x4)-v2.1
//!BIND LUMANE

vec4 hook() {
	return vec4(LUMANE_tex(HOOKED_pos).y + HOOKED_tex(HOOKED_pos).x, HOOKED_tex(HOOKED_pos).yz, 0);
}

/* ---------------------- Gradient Push ---------------------- */


//!DESC Anime4K-Hybrid-ComputeGradientX-v2.1
//!HOOK SCALED
//!BIND HOOKED
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAD
//!COMPONENTS 2

float getLum(vec4 rgb) {
	return 0.299*rgb.r + 0.587*rgb.g + 0.114*rgb.b;
}

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = getLum(HOOKED_tex(HOOKED_pos + vec2(-d.x, 0)));
	float c = getLum(HOOKED_tex(HOOKED_pos));
	float r = getLum(HOOKED_tex(HOOKED_pos + vec2(d.x, 0)));
	
	
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


//!DESC Anime4K-Hybrid-ComputeGradientY-v2.1
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAD
//!COMPONENTS 2


/* --------------------- SETTINGS --------------------- */

//Strength of edge refinement, good values are between 0.2 and 4
#define REFINE_STRENGTH 1


/* --- MODIFY THESE SETTINGS BELOW AT YOUR OWN RISK --- */

//Bias of the refinement function, good values are between 0 and 1
#define REFINE_BIAS 0

//Polynomial fit obtained by minimizing MSE error on image
#define P5 ( 11.68129591)
#define P4 (-42.46906057)
#define P3 ( 60.28286266)
#define P2 (-41.84451327)
#define P1 ( 14.05517353)
#define P0 (-1.081521930)

//Power curve used to ease in upscaling smaller than 2x upscaling factors.
#define UPSCALE_RATIO_HYSTERESIS 1

/* ----------------- END OF SETTINGS ----------------- */

float power_function(float x) {
	float x2 = x * x;
	float x3 = x2 * x;
	float x4 = x2 * x2;
	float x5 = x2 * x3;
	
	return P5*x5 + P4*x4 + P3*x3 + P2*x2 + P1*x + P0;
}

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
	float sobel_norm = clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1);
	
	float upratio = clamp(SCALED_size.x / LUMA_size.x - 1, 0, 6);
	
	float dval = clamp(power_function(clamp(sobel_norm * max(pow(upratio, UPSCALE_RATIO_HYSTERESIS), 1), 0, 1)) * REFINE_STRENGTH + REFINE_BIAS, 0, 1);
	
	if (upratio < 1) {
		dval = dval * pow(upratio, UPSCALE_RATIO_HYSTERESIS);
	}
	
	return vec4(sobel_norm, dval, 0, 0);
}

//!DESC Anime4K-Hybrid-ComputeSecondGradientX-v2.1
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 2


vec4 hook() {
	vec2 d = HOOKED_pt;
	
	if (LUMAD_tex(HOOKED_pos).y < 0.1) {
		return vec4(0);
	}
	
	//[tl  t tr]
	//[ l  c  r]
	//[bl  b br]
	float l = LUMAD_tex(HOOKED_pos + vec2(-d.x, 0)).x;
	float c = LUMAD_tex(HOOKED_pos).x;
	float r = LUMAD_tex(HOOKED_pos + vec2(d.x, 0)).x;
	
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
	
	
	return vec4(xgrad, ygrad, 0, 0);
}


//!DESC Anime4K-Hybrid-ComputeSecondGradientY-v2.1
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMAD
//!BIND LUMAMM
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *
//!SAVE LUMAMM
//!COMPONENTS 2

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	if (LUMAD_tex(HOOKED_pos).y < 0.1) {
		return vec4(0);
	}
	
	//[tl  t tr]
	//[ l cc  r]
	//[bl  b br]
	float tx = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y)).x;
	float cx = LUMAMM_tex(HOOKED_pos).x;
	float bx = LUMAMM_tex(HOOKED_pos + vec2(0, d.y)).x;
	
	float ty = LUMAMM_tex(HOOKED_pos + vec2(0, -d.y)).y;
	//float cy = LUMAMM_tex(HOOKED_pos).y;
	float by = LUMAMM_tex(HOOKED_pos + vec2(0, d.y)).y;
	
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
	
	float norm = sqrt(xgrad * xgrad + ygrad * ygrad);
	if (norm <= 0.001) {
		xgrad = 0;
		ygrad = 0;
		norm = 1;
	}
	
	return vec4(xgrad/norm, ygrad/norm, 0, 0);
}

//!DESC Anime4K-Hybrid-Refine-v2.1
//!HOOK SCALED
//!BIND HOOKED
//!BIND LUMA
//!BIND LUMAD
//!BIND LUMAMM
//!BIND LUMANE
//!WHEN OUTPUT.w LUMA.w / 1.200 > OUTPUT.h LUMA.h / 1.200 > *

#define ML_SENSITIVITY 0.4 //Sensitivity for not applying refine step on pixels already refined by prior steps

vec4 hook() {
	vec2 d = HOOKED_pt;
	
	
	float dval = (1 - clamp(abs(LUMANE_tex(HOOKED_pos).x + LUMANE_tex(HOOKED_pos).y) / ML_SENSITIVITY, 0, 1)) * LUMAD_tex(HOOKED_pos).y;
	
	if (dval < 0.1) {
		return SCALED_tex(HOOKED_pos);
	}
	
	vec4 dc = LUMAMM_tex(HOOKED_pos);
	if (abs(dc.x + dc.y) <= 0.0001) {return SCALED_tex(HOOKED_pos);
	}
	
	float xpos = -sign(dc.x);
	float ypos = -sign(dc.y);
	
	vec4 xval = SCALED_tex(HOOKED_pos + vec2(d.x * xpos, 0));
	vec4 yval = SCALED_tex(HOOKED_pos + vec2(0, d.y * ypos));
	
	float xyratio = abs(dc.x) / (abs(dc.x) + abs(dc.y));
	
	vec4 avg = xyratio * xval + (1-xyratio) * yval;
	
	return avg * dval + SCALED_tex(HOOKED_pos) * (1 - dval);
}

