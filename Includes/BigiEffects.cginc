﻿#ifndef BIGI_EFFECTS_INCLUDE
#define BIGI_EFFECTS_INCLUDE
#include <HLSLSupport.cginc>
#include "./ColorUtil.cginc"
#include "./SoundUtilsDefines.cginc"

#ifndef BIGI_LYGIA_PATCHES
#ifndef RANDOM_SCALE_4
#define RANDOM_SCALE_4 float4(443.897, 441.423, .0973, 1.6334)
#endif
#endif
#include <Assets/lygia/generative/voronoi.hlsl>


namespace b_effects
{
    struct BEffectsTracker {
        float totalWeight;
        fixed3 totalColor;
    };

    void doMixProperly(inout BEffectsTracker obj, in fixed3 color, in float weight, in float force)
    {
        obj.totalWeight += weight;
        obj.totalColor = lerp(obj.totalColor, color, (weight * force) / obj.totalWeight);
    }

    fixed4 Monochromize(fixed4 input, float enabled)
    {
        half colorValue = RGBToHSV(input.rgb * input.a).z;
        //colorValue = smoothstep(0.4,0.6,colorValue);
        fixed4 ret = fixed4(colorValue, colorValue, colorValue, input.a);
        return lerp(input, ret, enabled);
    }

    float3 get_voronoi(in half2 uv)
    {
        float3 voronoiOutput = voronoi(uv * 10.0, b_sound::GetTimeRaw());
        return HSVToRGB(half3((voronoiOutput.x + voronoiOutput.y) / 2.0f, 1.0, 1.0));
    }

    // float3 get_quantize()
    // {
    //     return float3(0,0,0);
    // }

    fixed4 apply_effects(in half2 uv, in fixed4 mask, in fixed4 orig_color, in fixed4 lighting, in float4 staticTexturePos)
    {
        const float3 fixedLighting = lighting.rgb * lighting.a;
        BEffectsTracker mix;
        mix.totalWeight = 1.0;
        mix.totalColor = orig_color.rgb * fixedLighting;
        //AudioLink
        {
            GET_SOUND_COLOR(soundC);
            doMixProperly(mix, soundC.rgb, mask.b * RGBtoHCV(soundC).z * soundC.a, 2.0);
        }
        //"Emissions"
        {
            doMixProperly(mix, orig_color.rgb * _EmissionStrength, mask.r * _EmissionStrength, 1.0);
        }
        //Screenspace images
        {
            const half2 screen_texture_pos = TRANSFORM_TEX((staticTexturePos.xy / staticTexturePos.w), _Spacey);
            doMixProperly(mix,UNITY_SAMPLE_TEX2D(_Spacey, screen_texture_pos), mask.g, 1.0);
        }

        //Voronoi
        {
            if (_Voronoi > Epsilon)
            {
                doMixProperly(mix, get_voronoi(uv) * fixedLighting, _Voronoi, 2.0);
            }
        }

        // //Quantize
        // {
        //     if(0 > Epsilon)
        //     {
        //         
        //     }
        // }
        return Monochromize(half4(mix.totalColor, orig_color.a), _MonoChrome);
    }
}

#endif
