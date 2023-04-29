//
//  SkyboxPass.swift
//  PoorEngine
//
//  Created by Reuben on 2023/4/29.
//

import MetalKit

class SkyboxPass: SubPass{
    var subPassPSO: MTLRenderPipelineState
    
    var depthStencilState: MTLDepthStencilState?
    
    required init(view: MTKView, options: Options) {
        subPassPSO = PipelineStates.createSkyboxPSO(colorPixelFormat: view.colorPixelFormat)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        if options.drawSkybox == false {
            return
        }
        renderEncoder.pushDebugGroup("Skybox")
        renderEncoder.label = "Skybox render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(subPassPSO)
        
        let skybox = cullingResult.skybox
        
        renderEncoder.setVertexBuffer(skybox?.mesh.vertexBuffers[0].buffer,
                                      offset: 0,
                                      index: 0)
        var uniforms = uniforms
        uniforms.modelMatrix = (skybox?.transform.modelMatrix)!
        uniforms.viewMatrix.columns.3 = [0, 0, 0, 1]
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: UniformsBuffer.index)
        renderEncoder.setFragmentTexture(skybox?.skyTexture, index: SkyboxTexture.index)
        
        let submesh = skybox?.mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: submesh!.indexCount,
                                            indexType: submesh!.indexType,
                                            indexBuffer: submesh!.indexBuffer.buffer,
                                            indexBufferOffset: 0)
        renderEncoder.popDebugGroup()
    }
    
    
}
