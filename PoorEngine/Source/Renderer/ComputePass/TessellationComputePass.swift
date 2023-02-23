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
    
    let patches = (horizontal: 6, vertical: 6)
    var patchCount: Int {
        patches.horizontal * patches.vertical
    }
    
    var edgeFactors: [Float] = [4]
    var insideFactors: [Float] = [4]
    
    var tessellationFactorsBuffer: MTLBuffer?
    
    var controlPointsBuffer: MTLBuffer?
    
    var terrain = Terrain(size: [8, 8], height: 1, maxTessellation: UInt32(Quad.maxTessellation))
    

    
    init(view: MTKView, options: Options){
        tessellationComputePSO = PipelineStates.createComputePSO(function: "tessellation_main")
        
        let controlPoints = Quad.createControlPoints(patches: patches, size: (terrain.size.x, terrain.size.y))
        controlPointsBuffer = RHI.device.makeBuffer(bytes: controlPoints,
                                                    length: MemoryLayout<float3>.stride * controlPoints.count)
        
        tessellationFactorsBuffer = RHI.device.makeBuffer(
            length: patchCount * (4 + 2) * MemoryLayout<Float>.size / 2,
            options: .storageModePrivate)
    }
    
    func tessellation(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult) {
        if cullingResult.terrainQuad == nil {
            return
        }
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        computeEncoder.setComputePipelineState(tessellationComputePSO)
        var edgeFactors = edgeFactors
        computeEncoder.setBytes(&edgeFactors,
                                length: MemoryLayout<Float>.size * edgeFactors.count,
                                index: 0)
        var insideFactors = insideFactors
        computeEncoder.setBytes(&insideFactors,
                                length: MemoryLayout<Float>.size * insideFactors.count,
                                index: 1)
        computeEncoder.setBuffer(tessellationFactorsBuffer,
                                 offset: 0,
                                 index: 2)
        
        var cameraPos = float4(cullingResult.camera.position, 0)
        computeEncoder.setBytes(&cameraPos,
                                length: MemoryLayout<float4>.stride,
                                index: 3)
        var matrix = cullingResult.terrainQuad!.transform.modelMatrix
        computeEncoder.setBytes(&matrix,
                                length: MemoryLayout<float4x4>.stride,
                                index: 4)
        computeEncoder.setBuffer(controlPointsBuffer,
                                 offset: 0,
                                 index: 5)
        var terrain = terrain
        computeEncoder.setBytes(&terrain,
                                length: MemoryLayout<Terrain>.stride,
                                index: 6)
        
        let width = min(patchCount, tessellationComputePSO.threadExecutionWidth)
        let gridSize = MTLSize(width: patchCount, height: 1, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: width, height: 1, depth: 1)
        computeEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()
    }
}
