//
//  Terrain.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/22.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/CustomCore.h"

struct TerrainVertexIn {
    float4 position [[attribute(0)]];
};

vertex VertexOut vertex_terrain(TerrainVertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(11)]])
{
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.normal = 0;
    out.uv = 0;
    out.color = 0;
    out.positionWS = 0;
    out.normalWS = 0;
    out.tangentWS = 0;
    out.bitangentWS = 0;
    out.shadowPosition = 0;
    return out;
}
