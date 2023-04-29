//
//  TerrainPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

class TerrainPass: SubPass{
    var subPassPSO: MTLRenderPipelineState
    
    var depthStencilState: MTLDepthStencilState?
    
    var heightMap: MTLTexture?
    var cliffTexture: MTLTexture?
    var snowTexture: MTLTexture?
    var grassTexture: MTLTexture?
    
    var tessellationFactorsBuffer: MTLBuffer?
    var controlPointsBuffer: MTLBuffer?
    var terrain: Terrain?
    var patchCount: Int?
    
    required init(view: MTKView, options: Options) {
        subPassPSO = PipelineStates.createTerrainPSO(colorPixelFormat: view.colorPixelFormat)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        if cullingResult.terrainQuad == nil {
            return
        }
        renderEncoder.pushDebugGroup("Terrain")
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(subPassPSO)
        //        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        var uniforms = uniforms
        uniforms.modelMatrix = cullingResult.terrainQuad!.transform.modelMatrix
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)
        
        var params = params
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)
        
        // draw
        renderEncoder.setTessellationFactorBuffer(tessellationFactorsBuffer, offset: 0, instanceStride: 0)
        
        renderEncoder.setVertexBuffer(
            controlPointsBuffer,
            offset: 0,
            index: 0)
        
        if options.useHeightmap {
            renderEncoder.setVertexTexture(heightMap, index: 0)
        }
        
        var terrain = terrain
        renderEncoder.setVertexBytes(&terrain, length: MemoryLayout<Terrain>.stride, index: TerrainBuffer.index)
        
        renderEncoder.setFragmentTexture(cliffTexture, index: 1)
        renderEncoder.setFragmentTexture(snowTexture, index: 2)
        renderEncoder.setFragmentTexture(grassTexture, index: 3)
        
        // MARK: 线框debug，由于我们使用TBDR，只有一个Encoder，因此执行CS后要恢复.fill
        renderEncoder.setTriangleFillMode(options.drawTriangle ? .fill : .lines)
        
        renderEncoder.drawPatches(
            numberOfPatchControlPoints: 4,
            patchStart: 0,
            patchCount: patchCount!,
            patchIndexBuffer: nil,
            patchIndexBufferOffset: 0,
            instanceCount: 1,
            baseInstance: 0)
        
        renderEncoder.setTriangleFillMode(.fill)
        renderEncoder.popDebugGroup()
    }
    
    
}
