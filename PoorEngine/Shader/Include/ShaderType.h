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

#define DEBUG_NORMAL_WS     1
#define DEBUG_ALBEDO        2
#define DEBUG_METALLIC      3
#define DEBUG_ROUGHNESS     4
#define DEBUG_AO            5
#define DEBUG_SHININESS     6
#define DEBUG_DIFFUSE       7
#define DEBUG_SPECULAR      8
#define DEBUG_LIGHTONLY     9

#define TONEMAPPING_NONE    0
#define TONEMAPPING_LINEAR  1
#define TONEMAPPING_FILMIC  2
#define TONEMAPPING_LUMA    3
#define TONEMAPPING_WHITE   4

typedef enum DebugFunctionConstant {
    ShaderedFunctionConstantIndex,
    AlbedoFunctionConstantIndex
} DebugFunctionConstant;

void getDebugColor(Material mat, Params params, device float3& debugColor, float3 color, float3 normal);

constant bool is_shadered [[function_constant(ShaderedFunctionConstantIndex)]];
constant bool is_albedo [[function_constant(AlbedoFunctionConstantIndex)]];

#endif /* ShaderType_h */
