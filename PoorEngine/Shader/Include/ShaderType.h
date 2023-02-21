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

typedef enum DebugFunctionConstant {
    ShaderedFunctionConstantIndex,
    AlbedoFunctionConstantIndex
} DebugFunctionConstant;

float3 getDebugColor(Material mat, Params params, float3 color);

constant bool is_shadered [[function_constant(ShaderedFunctionConstantIndex)]];
constant bool is_albedo [[function_constant(AlbedoFunctionConstantIndex)]];

#endif /* ShaderType_h */
