﻿#pragma once

#include "./BigiSoundUtils.cginc"
#include "./BigiShaderParams.cginc"



#define GET_SOUND_SETTINGS(set) b_sound::ALSettings set; \
set.AL_Theme_Weight = _AL_Theme_Weight; \
set.AL_Hue_Weight = _AL_Hue_Weight; \
set.AL_Hue = _AL_Hue; \
set.AL_Hue_BassReactive = _AL_Hue_BassReactive; \
set.AL_TC_BassReactive = _AL_TC_BassReactive;

#define GET_SOUND_COLOR_CALL(setin,lout) const half4 lout = b_sound::GetDMXOrALColor(setin);

#define GET_SOUND_COLOR(outName) GET_SOUND_SETTINGS(bsoundSet); GET_SOUND_COLOR_CALL(bsoundSet,outName);
