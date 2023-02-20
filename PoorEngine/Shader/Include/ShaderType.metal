//
//  ShaderType.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderType.h"

constant bool is_shadered [[function_constant(ShaderedFunctionConstantIndex)]];
constant bool is_albedo [[function_constant(AlbedoFunctionConstantIndex)]];
