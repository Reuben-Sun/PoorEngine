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

