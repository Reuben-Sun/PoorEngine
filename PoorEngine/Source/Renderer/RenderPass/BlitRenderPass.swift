//
//  BlitRenderPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/30.
//

import MetalKit

struct BlitRenderPass: RenderPass{
    var label = "Blit Render Pass"
    
    var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
    
    var pipelineState: MTLRenderPipelineState
    
    var sourceTexture: MTLTexture?
    var targetTexture: MTLTexture?
    
    var options: Options
        
    init(view: MTKView, options: Options) {
        pipelineState = PipelineStates.createBlitPSO(colorPixelFormat: view.colorPixelFormat)
        self.options = options
    }
        
    mutating func resize(view: MTKView, size: CGSize) {
    }
    
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        guard let descriptor = descriptor else { return }
        descriptor.colorAttachments[0].texture = targetTexture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = params
        renderEncoder.setFragmentBytes(&params,
                                       length: MemoryLayout<Params>.stride,
                                       index: ParamsBuffer.index)
        renderEncoder.setFragmentTexture(sourceTexture, index: 1)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.endEncoding()
    }
    
    
}
