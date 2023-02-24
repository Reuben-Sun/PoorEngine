//
//  PostProcess.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/24.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"

fragment float4 fragment_postprocess(VertexOut in [[stage_in]],
                                                constant Params &params [[buffer(ParamsBuffer)]],
                                                constant Light *lights [[buffer(LightBuffer)]])
{
    return float4(1, 1, 1, 1);
}

