//
//  Submesh.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    let textures: Textures
    let material: Material
    
    struct Textures{
        let baseColor: MTLTexture?
        let normal: MTLTexture?
        let roughness: MTLTexture?
        let metallic: MTLTexture?
        let ambientOcclusion: MTLTexture?
    }
}

extension Submesh {
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        indexCount = mtkSubmesh.indexCount
        indexType = mtkSubmesh.indexType
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
        textures = Textures(material: mdlSubmesh.material)
        material = Material(material: mdlSubmesh.material)
    }
}

extension Submesh.Textures{
    init(material: MDLMaterial?){
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                  property.type == .string,
                  let filename = property.stringValue,
                  let texture = TextureController.texture(filename: filename) else{
                      return nil
                  }
            return texture
        }
        //MARK: 设置mtl文件中贴图名称，比如金属度贴图就叫"map_metallic"
        baseColor = property(with: MDLMaterialSemantic.baseColor)
        normal = property(with: .tangentSpaceNormal)
        roughness = property(with: .roughness)
        metallic = property(with: .metallic)
        ambientOcclusion = property(with: .ambientOcclusion)
    }
}

extension Material {
    init(material: MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor),
           baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        if let specular = material?.property(with: .specular),
           specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        if let shininess = material?.property(with: .specularExponent),
           shininess.type == .float3 {
            self.shininess = shininess.float3Value
        }
        if let roughness = material?.property(with: .roughness),
           roughness.type == .float3{
            self.roughness = roughness.floatValue
        }
        self.ambientOcclusion = 1
        if let metallic = material?.property(with: .metallic),
           metallic.type == .float3 {
            self.metallic = metallic.floatValue
        }
        if let ambientOcclusion = material?.property(with: .ambientOcclusion),
           ambientOcclusion.type == .float3 {
            self.ambientOcclusion = ambientOcclusion.floatValue
        }
    }
}

