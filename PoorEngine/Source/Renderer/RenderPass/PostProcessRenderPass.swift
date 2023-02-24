//
//  PostProcessRenderPass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/24.
//

import MetalKit

struct PostProcessRenderPass: RenderPass {
    var label = "Post Process Render Pass"
    
    var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
    
    var pipelineState: MTLRenderPipelineState
    
    var preTexture: MTLTexture?
    var currentTexture: MTLTexture?
    
    var options: Options
    
    init(view: MTKView, options: Options) {
        pipelineState = PipelineStates.createPostProcessPSO(colorPixelFormat: view.colorPixelFormat)
        self.options = options
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
        currentTexture = Self.makeTexture(
            size: size,
            pixelFormat: .bgra8Unorm,
            label: "Current Texture",
            storageMode: .shared)
    }
    
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        guard let descriptor = descriptor else { return }
        descriptor.colorAttachments[0].texture = currentTexture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = params
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)
        renderEncoder.setFragmentTexture(preTexture, index: 1)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.endEncoding()
    }
    
    
}
