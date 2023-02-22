//
//  Tessellation.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/22.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Common.h"

kernel void tessellation_main(constant float *edge_factors [[buffer(0)]],
                              constant float *inside_factors [[buffer(1)]],
                              device MTLQuadTessellationFactorsHalf
                              *factors [[buffer(2)]],
                              uint pid [[thread_position_in_grid]])
{
    factors[pid].edgeTessellationFactor[0] = edge_factors[0];
    factors[pid].edgeTessellationFactor[1] = edge_factors[0];
    factors[pid].edgeTessellationFactor[2] = edge_factors[0];
    factors[pid].edgeTessellationFactor[3] = edge_factors[0];

    factors[pid].insideTessellationFactor[0] = inside_factors[0];
    factors[pid].insideTessellationFactor[1] = inside_factors[0];
}

