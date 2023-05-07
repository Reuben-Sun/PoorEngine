//
//  Heightmap.metal
//  PoorEngine
//
//  Created by Reuben on 2023/5/7.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"

fragment float4 fragment_heightmap(VertexOut in [[stage_in]],
                                   constant Params &params [[buffer(ParamsBuffer)]])
{
    return float4(0.5, 0.5, 0.5, 1);
}
