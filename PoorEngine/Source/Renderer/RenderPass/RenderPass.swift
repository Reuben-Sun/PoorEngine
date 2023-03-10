//
//  RenderPass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

/// 所有渲染管线的基类
protocol RenderPass {
    var label: String { get }
    var descriptor: MTLRenderPassDescriptor? { get set }
    mutating func resize(view: MTKView, size: CGSize)
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options)
}

extension RenderPass{
    /// 构建深度测试
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return RHI.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    static func makeTexture(size: CGSize,
                            pixelFormat: MTLPixelFormat,
                            label: String,
                            storageMode: MTLStorageMode = .private,
                            usage: MTLTextureUsage = [.shaderRead, .renderTarget]
    ) -> MTLTexture? {
        let width = Int(size.width)
        let height = Int(size.height)
        guard width > 0 && height > 0 else { return nil }
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                   width: width,
                                                                   height: height,
                                                                   mipmapped: false)
        textureDesc.storageMode = storageMode
        textureDesc.usage = usage
        guard let texture = RHI.device.makeTexture(descriptor: textureDesc) else {
            fatalError("Failed to create texture")
        }
        texture.label = label
        return texture
    }
    
    static func makeMultisampleTexture(size: CGSize,
                                       pixelFormat: MTLPixelFormat,
                                       label: String,
                                       storageMode: MTLStorageMode = .private,
                                       usage: MTLTextureUsage = [.shaderRead, .renderTarget],
                                       sampleCount: Int = 1)
    -> MTLTexture? {
        let width = Int(size.width)
        let height = Int(size.height)
        guard width > 0 && height > 0 else { return nil }
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                   width: width,
                                                                   height: height,
                                                                   mipmapped: false)
        textureDesc.storageMode = storageMode
        textureDesc.usage = usage
        textureDesc.sampleCount = sampleCount
        textureDesc.textureType  = MTLTextureType.type2DMultisample
        guard let texture = RHI.device.makeTexture(descriptor: textureDesc) else {
            fatalError("Failed to create texture")
        }
        texture.label = label
        return texture
    }
}

