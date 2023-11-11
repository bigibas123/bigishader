#ifndef BIGI_LIGHT_UTILS_INCLUDE
#define BIGI_LIGHT_UTILS_INCLUDE

#include <UnityCG.cginc>
#include <UnityStandardConfig.cginc>
#include <UnityStandardUtils.cginc>


namespace b_light
{
    // A macro instead of a function because this works on more types without having to overload it a bunch of times
    // ReSharper disable once CppInconsistentNaming
    # define doStep(val) smoothstep(0.0, lightDiffuseness, val)

    half3 GetAmbient(
        const in float4 worldLightPos,
        const in float3 worldNormal,
        const in float minAmbient,
        const in float4 ambientOcclusion,
        const in float3 vertexAmbient
    )
    {
        half3 ret = 0;

        #if UNITY_SHOULD_SAMPLE_SH
        ret = ShadeSHPerPixel(worldNormal, vertexAmbient, worldLightPos);
        #endif

        #if defined(LIGHTMAP_ON)
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);
        
        #ifdef DIRLIGHTMAP_COMBINED
        fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
        ret += DecodeDirectionalLightmap(bakedColor, bakedDirTex, normalWorld);
        #else // not directional lightmap
        ret += bakedColor;
        #endif
        #endif

        
        return max(ret,minAmbient) * clamp(ambientOcclusion, 0.75, 1.0);
    }

    fixed3 GetWorldLightIntensity(
        const in half shadowAttenuation,
        const in float4 worldLightPos,
        const in float3 worldNormal
    )
    {
        const float nl = max(0, dot(worldNormal, worldLightPos.xyz));
        const float lightIntensity = nl * shadowAttenuation;
        return lightIntensity;
    }

    fixed4 GetLighting(
        const in float4 worldLightPos,
        const in float3 worldNormal,
        const in half shadowAttenuation,
        const in half4 lightColor,
        const in float3 vertex,
        const in float minAmbient,
        const in float4 ambientOcclusion,
        const in float lightDiffuseness
    )
    {
        const half3 ambient = GetAmbient(worldLightPos, worldNormal, minAmbient, ambientOcclusion, vertex);

        const float nl = max(0, dot(worldNormal, worldLightPos.xyz));

        const float lightIntensity = doStep(nl * shadowAttenuation);
        const fixed3 vertexStepped = vertex;
        const fixed3 diff = lightIntensity * lightColor;

        return fixed4(diff + ambient + vertexStepped, 1.0);
    }

    //Unity.cginc Shade4PointLights 
    float3 bigi_Shade4PointLights(
        float4 lightPosX, float4 lightPosY, float4 lightPosZ,
        float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
        float4 lightAttenSq,
        float3 pos, float3 normal, in const float lightDiffuseness
    )
    {
        // to light vectors
        float4 toLightX = lightPosX - pos.x;
        float4 toLightY = lightPosY - pos.y;
        float4 toLightZ = lightPosZ - pos.z;
        // squared lengths
        float4 lengthSq = 0;
        lengthSq += toLightX * toLightX;
        lengthSq += toLightY * toLightY;
        lengthSq += toLightZ * toLightZ;
        // don't produce NaNs if some vertex position overlaps with the light
        lengthSq = max(lengthSq, 0.000001);

        // NdotL
        float4 ndotl = 0;
        ndotl += toLightX * normal.x;
        ndotl += toLightY * normal.y;
        ndotl += toLightZ * normal.z;
        // correct NdotL
        float4 corr = rsqrt(lengthSq);
        ndotl = max(float4(0, 0, 0, 0), ndotl * corr);
        // attenuation
        float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
        float4 diff = doStep(ndotl * atten);
        // final color
        float3 col = 0;
        col += lightColor0 * diff.x;
        col += lightColor1 * diff.y;
        col += lightColor2 * diff.z;
        col += lightColor3 * diff.w;
        return col;
    }

    float3 ProcessVertexLights(
        float4 lightPosX, float4 lightPosY, float4 lightPosZ,
        float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
        float4 lightAttenSq,
        float3 pos, float3 normal, in const float lightDiffuseness
    )
    {
        float3 ret = 0;
        #ifndef LIGHTMAP_ON
        #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
        ret = 0;
        
        #ifdef VERTEXLIGHT_ON
        ret += bigi_Shade4PointLights (
            lightPosX, lightPosY, lightPosZ,
            lightColor0, lightColor1, lightColor2, lightColor3,
            lightAttenSq, pos, normal, lightDiffuseness);
        #endif
        
        ret = ShadeSHPerVertex (normal, ret);
        #endif

        #endif
        return ret;
    }

    fixed4 GetLighting(
        const in float4 worldLightPos,
        const float3 normal,
        const half shadowAttenuation,
        const half4 lightColor,
        const float3 vertex,
        const float minAmbient,
        const float lightDiffuseness
    )
    {
        return GetLighting(worldLightPos, normal, shadowAttenuation, lightColor, vertex, minAmbient, 1.0, lightDiffuseness);
    }
}

#endif
