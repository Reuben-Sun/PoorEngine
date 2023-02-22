//
//  TessellationComputePass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/22.
//

import MetalKit

struct TessellationComputePass {
    var label = "Tessellation Compute Pass"
    // 曲面细分PSO
    var tessellationComputePSO: MTLComputePipelineState
    
    //TODO: terrain代码，后续会进行迁移
    let patches = (horizontal: 6, vertical: 6)
    var patchCount: Int {
        patches.horizontal * patches.vertical
    }
    var edgeFactors: [Float] = [4]
    var insideFactors: [Float] = [4]
    lazy var tessellationFactorsBuffer: MTLBuffer? = {
        // 1
        let count = patchCount * (4 + 2)
        // 2
        let size = count * MemoryLayout<Float>.size / 2
        return RHI.device.makeBuffer(length: size, options: .storageModePrivate)
    }()
    var controlPointsBuffer: MTLBuffer?
    
    init(view: MTKView, options: Options){
        tessellationComputePSO = PipelineStates.createComputePSO(function: "tessellation_main")
        
        let controlPoints = Quad.createControlPoints(patches: patches, size: (2, 2))
        controlPointsBuffer = RHI.device.makeBuffer(bytes: controlPoints,
                                                    length: MemoryLayout<float3>.stride * controlPoints.count)
    }
}
