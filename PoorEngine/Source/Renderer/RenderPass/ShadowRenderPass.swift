//
//  ShadowRenderPass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

struct ShadowRenderPass: RenderPass {
    let label: String = "Shadow Render Pass"
    var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
    var depthStencilState: MTLDepthStencilState? = Self.buildDepthStencilState()
    var pipelineState: MTLRenderPipelineState
    var shadowTexture: MTLTexture?
    
    init() {
        pipelineState = PipelineStates.createShadowPassPSO()
        shadowTexture = Self.makeTexture(size: CGSize(width: 2048, height: 2048),
                                         pixelFormat: .depth32Float,
                                         label: "Shadow Depth Texture")
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
    }
    
    func draw(commandBuffer: MTLCommandBuffer,
              cullingResult: CullingResult,
              uniforms: Uniforms,
              params: Params,
              options: Options) {
        guard let descriptor = descriptor else { return }
        descriptor.depthAttachment.texture = shadowTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = "Shadow"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        for model in cullingResult.models {
            renderEncoder.pushDebugGroup(model.name)
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params,
                options: options)
            renderEncoder.popDebugGroup()
        }
        renderEncoder.endEncoding()
    }
}

