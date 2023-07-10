﻿#ifndef BIGI_EFFECTS_INCLUDE
#define BIGI_EFFECTS_INCLUDE
#include <HLSLSupport.cginc>
#include "./ColorUtil.cginc"
#include "./Includes/SoundUtilsDefines.cginc"
#include "Assets/lygia/generative/voronoi.hlsl"

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

    fixed4 apply_effects(in v2f i, in fixed4 mask, in fixed4 orig_color, in fixed4 lighting)
    {
        BEffectsTracker mix;
        mix.totalWeight = 1.0;
        mix.totalColor = orig_color * lighting;
        //AudioLink
        {
            GET_SOUND_COLOR(soundC);
            doMixProperly(mix, soundC, mask.b * RGBtoHCV(soundC).z, 1.0);
        }
        //"Emissions"
        {
            doMixProperly(mix, orig_color, mask.r * _EmissionStrength - ((mix.totalWeight - 1.0) * _EmissionStrength), 1.0);
        }
        //Screenspace images
        {
            const half2 screen_texture_pos = TRANSFORM_TEX((i.staticTexturePos.xy / i.staticTexturePos.w), _Spacey);
            doMixProperly(mix,UNITY_SAMPLE_TEX2D(_Spacey, screen_texture_pos), mask.g, 1.0);
        }

        //Voronoi
        {
            if (_Voronoi > Epsilon)
            {
                doMixProperly(mix, get_voronoi(i.uv) * lighting, _Voronoi, 2.0);
            }
        }
        return Monochromize(half4(mix.totalColor, orig_color.a), _MonoChrome);
    }
}

#endif
