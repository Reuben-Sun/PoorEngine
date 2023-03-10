//
//  Skybox.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/26.
//

import MetalKit

class Skybox : Transformable {
    let mesh: MTKMesh
    var skyTexture: MTLTexture?
    var transform = Transform()
    
    init(textureName: String?) {
        let allocator = MTKMeshBufferAllocator(device: RHI.device)
//        let cube = MDLMesh(boxWithExtent: [1,1,1],
//                           segments: [1,1,1],
//                           inwardNormals: true,
//                           geometryType: .triangles,
//                           allocator: allocator)
        let sphere = MDLMesh(sphereWithExtent: [1, 1, 1],
                             segments: [20, 20],
                             inwardNormals: false,
                             geometryType: .triangles,
                             allocator: allocator)
        do {
            mesh = try MTKMesh(mesh: sphere, device: RHI.device)
        } catch {
            fatalError("Failed to create skybox mesh")
        }
        transform.position = [0, 0, 0]
        transform.rotation = [0, 0, 0]
    }
}
