// $MinimumShaderProfile: ps_2_0
sampler s0 : register(s0);
float4 p0 :  register(c0);
float4 p1 :  register(c1);

#define width   (p0[0])
#define height  (p0[1])
#define counter (p0[2])
#define clock   (p0[3])
#define one_over_width  (p1[0])
#define one_over_height (p1[1])
#define PI acos(-1)

float4 main(float2 tex : TEXCOORD0) : COLOR {
	float4 c0 = tex2D(s0, tex);
	
	//Quick luminance approximation
	float lum = (c0[0] + c0[0] + c0[1] + c0[1] + c0[1] + c0[2]) / 6;
	
	//Computes the luminance and saves it in the unused alpha channel
	return float4(c0[0], c0[1], c0[2], lum);
}
