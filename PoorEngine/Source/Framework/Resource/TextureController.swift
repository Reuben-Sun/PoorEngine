//
//  TextureController.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

enum TextureController {
    static var textures: [String: MTLTexture] = [:]
    
    /// 加载贴图
    static func loadTexture(filename: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: RHI.device)
        //优先使用Asset Catalog加载贴图
        if let texture = try? textureLoader.newTexture(name: filename, scaleFactor: 1.0, bundle: Bundle.main, options: nil){
            print("loaded texture: \(filename)")
            return texture
        }
        //贴图加载机制（零点位置，伽马矫正，Mipmap）
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft,
                                                                    .SRGB: false,
                                                                    .generateMipmaps: NSNumber(value: true)]
        let fileExtension = URL(fileURLWithPath: filename).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else{
            print("Failed to load \(filename)")
            return nil
        }
        
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
    
    /// 返回贴图，内置一个缓存机制
    static func texture(filename: String) -> MTLTexture? {
        if let tex = textures[filename] {
            return tex
        }
        let tex = try? loadTexture(filename: filename)
        if tex != nil {
            textures[filename] = tex
        }
        return tex
    }
}



