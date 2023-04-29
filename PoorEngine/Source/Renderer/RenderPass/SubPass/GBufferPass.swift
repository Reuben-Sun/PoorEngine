//
//  GBufferPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

class GBufferPass: SubPass{
    var subPassPSO: MTLRenderPipelineState
    var depthStencilState: MTLDepthStencilState?
    weak var shadowTexture: MTLTexture?
    
    required init(view: MTKView, options: Options) {
        subPassPSO = PipelineStates.createGBufferPassPSO(colorPixelFormat: view.colorPixelFormat, options: options)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        renderEncoder.pushDebugGroup("GBuffer")
        renderEncoder.label = "G-buffer render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(subPassPSO)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        
        for model in cullingResult.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params,
                options: options)
        }
        renderEncoder.popDebugGroup()
    }
    
}
