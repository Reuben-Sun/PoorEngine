//
//  Model.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

class Model: Transformable {
    var transform = Transform()
    let meshes: [Mesh]
    let name: String
    var tiling: UInt32 = 1
    let objectId: UInt32
    
    /// 模型加载
    /// - Parameters:
    ///   - name: 模型名称（含后缀）
    init(name: String, exten: String = "obj", objectId: UInt32 = 0) {
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: exten) else {
            fatalError("Model: \(name+exten) not found")
        }
        self.objectId = objectId
        let allocator = MTKMeshBufferAllocator(device: RHI.device)
        let asset = MDLAsset(
            url: assetURL,
            vertexDescriptor: .defaultLayout,
            bufferAllocator: allocator)
        
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        _ = mdlMeshes.map {
            mdlMesh in mdlMesh.addTangentBasis(
                forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                normalAttributeNamed: MDLVertexAttributeTangent,
                tangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: RHI.device))
        }
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        self.name = name
    }
}

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
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
}

