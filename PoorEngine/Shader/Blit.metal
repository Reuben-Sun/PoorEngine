//
//  Blit.metal
//  PoorEngine
//
//  Created by Reuben on 2023/4/30.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"

fragment float4 fragment_blit(VertexOut in [[stage_in]],
                              constant Params &params [[buffer(ParamsBuffer)]],
                              texture2d<float> sourceTexture [[texture(1)]])
{
    constexpr sampler sample(filter::linear, address::repeat);
    in.uv.y = -in.uv.y;
    float4 color = sourceTexture.sample(sample, in.uv);
    return float4(color.xyz, 1);
}
