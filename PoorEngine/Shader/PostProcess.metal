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

//fragment float4 fragment_postprocess(VertexOut in [[stage_in]],
//                                     constant Params &params [[buffer(ParamsBuffer)]],
//                                     texture2d<float> preTexture [[texture(1)]])
//{
//    constexpr sampler sample(filter::linear, address::repeat);
//    float tiling = 16.0;
//    float4 color = preTexture.sample(sample, in.uv);
//    return float4(color.xyz, 1);
//}
