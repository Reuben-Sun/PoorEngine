//
//  Skybox.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/26.
//

import MetalKit

struct Skybox {
    let mesh: MTKMesh
    var skyTexture: MTLTexture?
    var vertexDescriptor: MTLVertexDescriptor?
    
    init(textureName: String?) {
        let allocator = MTKMeshBufferAllocator(device: RHI.device)
        let cube = MDLMesh(boxWithExtent: [1,1,1],
                           segments: [1,1,1],
                           inwardNormals: true,
                           geometryType: .triangles,
                           allocator: allocator)
        vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(cube.vertexDescriptor)
        do {
            mesh = try MTKMesh(mesh: cube, device: RHI.device)
        } catch {
            fatalError("Failed to create skybox mesh")
        }
    }
}
