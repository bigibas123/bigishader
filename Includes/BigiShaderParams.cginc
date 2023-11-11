#ifndef BIGI_V1_SHADERPARAMS
#define BIGI_V1_SHADERPARAMS

#include <UnityShaderVariables.cginc>


#ifndef BIGI_V1_TEXTURES
#define BIGI_V1_TEXTURES
#include <HLSLSupport.cginc>

#ifndef MULTI_TEXTURE
    UNITY_DECLARE_TEX2D(_MainTex);
    float4 _MainTex_ST;
    #define GET_TEX_COLOR(uv) UNITY_SAMPLE_TEX2D(_MainTex, uv)
    #define GET_MASK_COLOR(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_Mask, _MainTex, uv)
    #define GET_AO(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_OcclusionMap, _MainTex, uv)
    #define GET_NORMAL(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, uv)

    #define DO_TRANSFORM(tc) TRANSFORM_TEX(v.texcoord, _MainTex);

#else
    UNITY_DECLARE_TEX2DARRAY(_MainTexArray);
    float4 _MainTexArray_ST;
    uniform int _OtherTextureId;
    #define GET_TEX_COLOR(uv) UNITY_SAMPLE_TEX2DARRAY(_MainTexArray, float3(uv,_OtherTextureId))
    #define GET_MASK_COLOR(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_Mask, _MainTexArray, uv)
    #define GET_AO(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_OcclusionMap, _MainTexArray, uv)
    #define GET_NORMAL(uv) UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTexArray, uv)

    #define DO_TRANSFORM(tc) TRANSFORM_TEX(v.texcoord, _MainTexArray);

#endif


UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask);
UNITY_DECLARE_TEX2D_NOSAMPLER(_OcclusionMap);
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
UNITY_DECLARE_TEX2D(_Spacey);
float4 _Spacey_ST;


#endif

#ifndef BIGI_UNIFORMS
#define BIGI_UNIFORMS

uniform float _DMX_Weight;
uniform float _AL_Theme_Weight;
uniform float _AL_Hue_Weight;

uniform uint _DMX_Group;
uniform half _AL_Hue;

uniform half _AL_Hue_BassReactive;
uniform half _AL_TC_BassReactive;

//Both
uniform float _OutlineWidth;
//Other
uniform half _EmissionStrength;
uniform float _AddLightIntensity;
uniform float _MinAmbient;

//Effects
uniform float _MonoChrome;
uniform float _Voronoi;
uniform float _LightDiffuseness;
#endif

#ifndef BIGI_DEFAULT_FRAGOUT
#define BIGI_DEFAULT_FRAGOUT

struct fragOutput {
    fixed4 color : SV_Target;
};
#endif

#ifndef BIGI_EPSILON
#define BIGI_EPSILON
#include <UnityCG.cginc>
#define Epsilon UNITY_HALF_MIN
#endif

#endif
