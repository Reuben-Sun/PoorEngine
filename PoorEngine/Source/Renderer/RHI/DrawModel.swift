//
//  DrawModel.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/23.
//

import MetalKit

// Rendering
extension Model {
    func render(encoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms,
                params fragment:Params, options: Options) {
        var uniforms = vertex
        var params = fragment
        
        uniforms.modelMatrix = transform.modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        params.tiling = tiling
        params.objectId = objectId
        
        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)
        
        encoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Uniforms>.stride,
            index: ParamsBuffer.index)
        
        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: index)
            }
            
            for submesh in mesh.submeshes {
                
                //传入贴图
                encoder.setFragmentTexture(submesh.textures.baseColor, index: BaseColor.index)
                encoder.setFragmentTexture(submesh.textures.normal, index: NormalTexture.index)
                encoder.setFragmentTexture(submesh.textures.roughness, index: RoughnessTexture.index)
                encoder.setFragmentTexture(submesh.textures.metallic,index: MetallicTexture.index)
                encoder.setFragmentTexture(submesh.textures.ambientOcclusion,index: AOTexture.index)
                //传入材质
                var material = submesh.material
                encoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: MaterialBuffer.index)
                //绘制
                encoder.drawIndexedPrimitives(
                    type: options.drawTriangle ? .triangle : .line,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
}

