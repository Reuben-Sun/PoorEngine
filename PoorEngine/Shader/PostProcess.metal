//
//  PostProcess.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/25.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"


fragment float4 fragment_postprocess(VertexOut in [[stage_in]],
                                     constant Params &params [[buffer(ParamsBuffer)]],
                                     texture2d<float> preTexture [[texture(1)]])
{
    constexpr sampler sample(filter::linear, address::repeat);
    in.uv.y = -in.uv.y;
    float4 color = preTexture.sample(sample, in.uv);
    return float4(color.xyz, 1);
}

kernel void msaa_main(imageblock<LightingOut> img_blk_colors,
                      uint pid [[thread_position_in_grid]])
{
    const ushort sampleCount = img_blk_colors.get_num_colors(pid);
    float4 resolved_color = float4(0.0);
    for(int i = 0; i < sampleCount; ++i){
        const float4 color = img_blk_colors.read(pid, i, imageblock_data_rate::color).Color;
        const ushort sampleColorCount = popcount(img_blk_colors.get_color_coverage_mask(pid, i));
        resolved_color += color * sampleColorCount;
    }
    resolved_color /= img_blk_colors.get_num_samples();
    
    const ushort output_sample_mask = 0xF;
    img_blk_colors.write(LightingOut{resolved_color}, pid, output_sample_mask);
}
