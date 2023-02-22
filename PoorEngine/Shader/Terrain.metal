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

[[patch(quad, 4)]]
vertex VertexOut vertex_terrain(patch_control_point<TerrainVertexIn> in [[stage_in]],
                                constant Uniforms &uniforms [[buffer(11)]],
                                float2 patch_coord [[position_in_patch]])
{
    float u = patch_coord.x;
    float v = patch_coord.y;

    VertexOut out;
//    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.position = float4(u,v,0,1);
    out.color = float3(u,v,0);
    return out;
}

fragment GBufferOut fragment_terrain_gBuffer(VertexOut in [[stage_in]],
                                             constant Params &params [[buffer(ParamsBuffer)]])
{
    
    GBufferOut out;
    out.MRT0 = float4(in.color,1);
    out.MRT1 = float4(0,1,0,0);
    out.MRT2 = float4(in.position.z, 0, 0, 0);
    return out;
}
