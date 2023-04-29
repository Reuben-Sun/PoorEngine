//
//  SubPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

protocol SubPass {
    var subPassPSO: MTLRenderPipelineState { get set }
    var depthStencilState: MTLDepthStencilState? { get set }
    init(view: MTKView, options: Options)
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options)
    
}
