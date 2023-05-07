//
//  HeightmapRenderPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/5/7.
//

import MetalKit

struct HeightmapRenderPass: RenderPass {
    var label: String = "Heightmap Render Pass"
    
    var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
    
    var pipelineState: MTLRenderPipelineState
    var heightmapTexture: MTLTexture?
    
    init(view: MTKView, options: Options){
        pipelineState = PipelineStates.createHeightmapPassPSO(colorPixelFormat: view.colorPixelFormat)
        heightmapTexture = Self.makeTexture(size: CGSize(width: 2048, height: 2048), pixelFormat: .rgba16Float, label: "Heightmap Texture")
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
        
    }
    
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        guard let descriptor = descriptor else { return }
        descriptor.colorAttachments[0].texture = heightmapTexture
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = "Heightmap"
        renderEncoder.setRenderPipelineState(pipelineState)
        var uniforms = uniforms
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: UniformsBuffer.index)
        var params = params
        params.lightCount = UInt32(cullingResult.sceneLights!.dirLights.count)
        renderEncoder.setFragmentBytes(&params,
                                       length: MemoryLayout<Params>.stride,
                                       index: ParamsBuffer.index)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.endEncoding()
        
    }
    
    
}
