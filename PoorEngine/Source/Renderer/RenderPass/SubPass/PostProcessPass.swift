//
//  PostProcessPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

class PostProcessPass: SubPass{
    var subPassPSO: MTLRenderPipelineState
    
    var depthStencilState: MTLDepthStencilState?
    
    required init(view: MTKView, options: Options) {
        subPassPSO = PipelineStates.createPostProcessPSO(colorPixelFormat: view.colorPixelFormat)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        renderEncoder.pushDebugGroup("Post Process")
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(subPassPSO)
        var params = params
        renderEncoder.setFragmentBytes(&params,
                                       length: MemoryLayout<Params>.stride,
                                       index: ParamsBuffer.index)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.popDebugGroup()
    }
    
    
}
