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
    var skySettings = SkySettings()
    
    init(textureName: String?) {
        let allocator = MTKMeshBufferAllocator(device: RHI.device)
        //        let cube = MDLMesh(boxWithExtent: [10,10,10],
        //                           segments: [5,5,5],
        //                           inwardNormals: true,
        //                           geometryType: .triangles,
        //                           allocator: allocator)
        let sphere = MDLMesh(sphereWithExtent: [10, 10, 10],
                             segments: [20, 20],
                             inwardNormals: true,
                             geometryType: .triangles,
                             allocator: allocator)
        do {
            mesh = try MTKMesh(mesh: sphere, device: RHI.device)
        } catch {
            fatalError("Failed to create skybox mesh")
        }
        skyTexture = loadGeneratedSkyboxTexture(textureName: "daySky", dimensions: [256, 256])
    }
    
    func loadGeneratedSkyboxTexture(textureName: String, dimensions: SIMD2<Int32>) -> MTLTexture? {
        var texture: MTLTexture?
        let skyTexture = MDLSkyCubeTexture(
            name: textureName,
            channelEncoding: .float16,
            textureDimensions: dimensions,
            turbidity: skySettings.turbidity,
            sunElevation: skySettings.sunElevation,
            upperAtmosphereScattering:skySettings.upperAtmosphereScattering,
            groundAlbedo: skySettings.groundAlbedo)
        do {
            let textureLoader = MTKTextureLoader(device: RHI.device)
            texture = try textureLoader.newTexture(texture: skyTexture, options: nil)
        } catch {
            print(error.localizedDescription)
        }
        return texture
    }
}

struct SkySettings {
    var turbidity: Float = 0.28
    var sunElevation: Float = 0.6
    var upperAtmosphereScattering: Float = 0.4
    var groundAlbedo: Float = 0.8
}

