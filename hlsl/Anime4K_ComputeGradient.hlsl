// $MinimumShaderProfile: ps_2_0
sampler s0 : register(s0);
float4 p0 :  register(c0);
float4 p1 :  register(c1);

#define width   (p0[0])
#define height  (p0[1])
#define counter (p0[2])
#define clock   (p0[3])
#define dx  (p1[0])
#define dy (p1[1])
#define PI acos(-1)

float4 main(float2 tex : TEXCOORD0) : COLOR {
	float4 c0 = tex2D(s0, tex);
	
	//[tl  t tr]
	//[ l     r]
	//[bl  b br]
	float t  = tex2D(s0, tex + float2(  0, -dy))[3];
	float tl = tex2D(s0, tex + float2(-dx, -dy))[3];
	float tr = tex2D(s0, tex + float2( dx, -dy))[3];
	
	float l  = tex2D(s0, tex + float2(-dx,   0))[3];
	float r  = tex2D(s0, tex + float2( dx,   0))[3];
	
	float b  = tex2D(s0, tex + float2(  0,  dy))[3];
	float bl = tex2D(s0, tex + float2(-dx,  dy))[3];
	float br = tex2D(s0, tex + float2( dx,  dy))[3];
	
	//Horizontal Gradient
	//[-1  0  1]
	//[-2  0  2]
	//[-1  0  1]
	float xgrad = (-tl + tr - l - l + r + r - bl + br);
	
	//Vertical Gradient
	//[-1 -2 -1]
	//[ 0  0  0]
	//[ 1  2  1]
	float ygrad = (-tl - t - t - tr + bl + b + b + br);
	
	//Computes the luminance's gradient and saves it in the unused alpha channel
	return float4(c0[0], c0[1], c0[2], 1 - clamp(sqrt(xgrad * xgrad + ygrad * ygrad), 0, 1));
}
