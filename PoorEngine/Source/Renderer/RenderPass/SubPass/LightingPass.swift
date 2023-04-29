//
//  LightingPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

class LightingPass: SubPass{
    var subPassPSO: MTLRenderPipelineState
    
    var depthStencilState: MTLDepthStencilState?
    
    required init(view: MTKView, options: Options) {
        subPassPSO = PipelineStates.createLightingPassPSO(colorPixelFormat: view.colorPixelFormat, options: options)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        renderEncoder.pushDebugGroup("Dir Light")
        renderEncoder.label = "Lighting render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        var uniforms = uniforms
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: UniformsBuffer.index)
        
        // MARK: DirLight support, Point Light un support
        renderEncoder.setRenderPipelineState(subPassPSO)
        var params = params
        params.lightCount = UInt32(cullingResult.sceneLights!.dirLights.count)
        renderEncoder.setFragmentBytes(&params,
                                       length: MemoryLayout<Params>.stride,
                                       index: ParamsBuffer.index)
        renderEncoder.setFragmentBuffer(cullingResult.sceneLights!.dirBuffer,
                                        offset: 0,
                                        index: LightBuffer.index)
        renderEncoder.setFragmentTexture(cullingResult.skybox?.skyTexture, index: SkyboxTexture.index)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.popDebugGroup()
    }
    
    
}
