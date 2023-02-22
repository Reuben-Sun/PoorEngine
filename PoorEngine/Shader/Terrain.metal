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
    // 顶点结构为
    // 0  1
    // 3  2
    // 这里是根据patch_coord进行插值
    float2 top = mix(in[0].position.xz, in[1].position.xz, u);
    float2 bottom = mix(in[3].position.xz, in[2].position.xz, u);
    // MARK: 由(top, bottom, v)改为(bottom, top, v)，以实现面片翻转
    float2 interpolated = mix(bottom, top, v);
    // 模型空间position
    float4 pos = float4(interpolated.x, 0.0, interpolated.y, 1.0);
    // NDC position
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * pos;
    // TODO: uv颜色方向好像不对
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
