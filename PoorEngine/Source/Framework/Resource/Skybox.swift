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
    var skyShape: SkyboxShape
    var transform = Transform()
    var skySettings = SkySettings()
    
    init(textureName: String, shape: SkyboxShape) {
        skyShape = shape
        let allocator = MTKMeshBufferAllocator(device: RHI.device)
        var shape = MDLMesh()
        if skyShape == .cube {
            shape = MDLMesh(boxWithExtent: [10,10,10],
                            segments: [5,5,5],
                            inwardNormals: true,
                            geometryType: .triangles,
                            allocator: allocator)
        }
        else if skyShape == .sphere {
            shape = MDLMesh(sphereWithExtent: [10, 10, 10],
                            segments: [20, 20],
                            inwardNormals: true,
                            geometryType: .triangles,
                            allocator: allocator)
        }
        do {
            mesh = try MTKMesh(mesh: shape, device: RHI.device)
        } catch {
            fatalError("Failed to create skybox mesh")
        }
        do {
            skyTexture = try TextureController.loadCubeTexture(imageName: textureName)
        } catch {
            fatalError("Failed to load skybox texture")
        }
        
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

enum SkyboxShape: String {
    case cube = "cube"
    case sphere = "sphere"
}

