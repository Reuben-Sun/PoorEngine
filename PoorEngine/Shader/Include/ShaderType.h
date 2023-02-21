//
//  ShaderType.h
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#ifndef ShaderType_h
#define ShaderType_h

#import "Common.h"
#import "CustomCore.h"

#define DEBUG_ALBEDO 2
#define DEBUG_METALLIC 3
#define DEBUG_ROUGHNESS 4
#define DEBUG_AO 5
#define DEBUG_SHININESS 6

typedef enum DebugFunctionConstant {
    ShaderedFunctionConstantIndex,
    AlbedoFunctionConstantIndex
} DebugFunctionConstant;

void getDebugColor(Material mat, Params params, device float3& debugColor, float3 color);

constant bool is_shadered [[function_constant(ShaderedFunctionConstantIndex)]];
constant bool is_albedo [[function_constant(AlbedoFunctionConstantIndex)]];

#endif /* ShaderType_h */
