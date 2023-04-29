//
//  TiledDeferredRenderPass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

struct TiledDeferredRenderPass: RenderPass{
    var label = "Tiled Deferred Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var gBufferPass: GBufferPass
    var lightingPass: LightingPass
    var skyboxPass: SkyboxPass
    var terrainPass: TerrainPass
    var postProcessPass: PostProcessPass
    
    var tessellationComputePass: TessellationComputePass
    
    let depthStencilState: MTLDepthStencilState?
    let lightingDepthStencilState: MTLDepthStencilState?
    let skyboxDepthStencilState: MTLDepthStencilState?
    
    weak var shadowTexture: MTLTexture?
    var albedoTexture: MTLTexture?
    var normalTexture: MTLTexture?
    var positionTexture: MTLTexture?
    var shinnessTexture: MTLTexture?
    
    var depthTexture: MTLTexture?
    
    var finalTexture: MTLTexture?
    
    var heightMap: MTLTexture?
    var cliffTexture: MTLTexture?
    var snowTexture: MTLTexture?
    var grassTexture: MTLTexture?
    
    init(view: MTKView, options: Options) {
        depthStencilState = Self.buildGBufferDepthStencilState()
        lightingDepthStencilState = Self.buildLightingDepthStencilState()
        skyboxDepthStencilState = Self.buildSkyboxDepthStencilState()
        
        tessellationComputePass = TessellationComputePass(view: view, options: options)
        
        gBufferPass = GBufferPass(view: view, options: options)
        gBufferPass.depthStencilState = depthStencilState
        lightingPass = LightingPass(view: view, options: options)
        lightingPass.depthStencilState = lightingDepthStencilState
        skyboxPass = SkyboxPass(view: view, options: options)
        skyboxPass.depthStencilState = skyboxDepthStencilState
        terrainPass = TerrainPass(view: view, options: options)
        terrainPass.depthStencilState = depthStencilState
        postProcessPass = PostProcessPass(view: view, options: options)
        postProcessPass.depthStencilState = depthStencilState
    }
    
    
    
    mutating func resize(view: MTKView, size: CGSize) {
        //将贴图类型设为memoryless
        albedoTexture = Self.makeTexture(
            size: size,
            pixelFormat: .bgra8Unorm,
            label: "Albedo Texture",
            storageMode: .memoryless)
        normalTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Normal Texture",
            storageMode: .memoryless)
        positionTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Position Texture",
            storageMode: .memoryless)
        shinnessTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Shiness Texture",
            storageMode: .memoryless)
        depthTexture = Self.makeTexture(
            size: size,
            pixelFormat: .depth32Float_stencil8,
            label: "Depth Texture",
            storageMode: .memoryless)
        finalTexture = Self.makeTexture(
            size: size,
            pixelFormat: .bgra8Unorm,
            label: "Final Texture",
            storageMode: .shared)
        
        do {
            heightMap = try TextureController.loadTexture(filename: "mountain")
            cliffTexture = try TextureController.loadTexture(filename: "cliff-color")
            snowTexture = try TextureController.loadTexture(filename: "snow-color")
            grassTexture = try TextureController.loadTexture(filename: "grass-color")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        guard let viewCurrentRenderPassDescriptor = descriptor else {
            return
        }
        // MARK: tesselation pass
        tessellationComputePass.tessellation(commandBuffer: commandBuffer, cullingResult: cullingResult)
        
        // MARK: TBDR
        let descriptor = viewCurrentRenderPassDescriptor
        descriptor.colorAttachments[0].texture = finalTexture
        descriptor.colorAttachments[0].texture?.label = "Final Texture"
        let textures = [
            albedoTexture,
            normalTexture,
            positionTexture,
            shinnessTexture
        ]
        //将贴图存储操作设为dontCare
        for (index, texture) in textures.enumerated() {
            let attachment =
            descriptor.colorAttachments[RenderTarget0.index + index]
            attachment?.texture = texture
            attachment?.loadAction = .clear
            attachment?.storeAction = .dontCare
            attachment?.clearColor =
            MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
        }
        descriptor.depthAttachment.texture = depthTexture
        descriptor.stencilAttachment.texture = depthTexture
        
        // TODO: 很离谱，显式指定Tile大小后，带宽、GPU时间大幅提高
        //        descriptor.tileWidth = 32
        //        descriptor.tileHeight = 32
        //        descriptor.threadgroupMemoryLength = MemoryLayout<Light>.size * 8
        
        guard let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor
                ) else { return }
        renderEncoder.label = "TBDR"
        
        gBufferPass.shadowTexture = shadowTexture
        gBufferPass.draw(renderEncoder: renderEncoder,
                         cullingResult: cullingResult,
                         uniforms: uniforms,
                         params: params,
                         options: options)
        
        terrainPass.heightMap = heightMap
        terrainPass.cliffTexture = cliffTexture
        terrainPass.snowTexture = snowTexture
        terrainPass.grassTexture = grassTexture
        terrainPass.tessellationFactorsBuffer = tessellationComputePass.tessellationFactorsBuffer
        terrainPass.controlPointsBuffer = tessellationComputePass.controlPointsBuffer
        terrainPass.terrain = tessellationComputePass.terrain
        terrainPass.patchCount = tessellationComputePass.patchCount
        terrainPass.draw(renderEncoder: renderEncoder,
                         cullingResult: cullingResult,
                         uniforms: uniforms,
                         params: params,
                         options: options)
        
        skyboxPass.draw(renderEncoder: renderEncoder,
                        cullingResult: cullingResult,
                        uniforms: uniforms,
                        params: params,
                        options: options)
        
        lightingPass.draw(renderEncoder: renderEncoder,
                          cullingResult: cullingResult,
                          uniforms: uniforms,
                          params: params,
                          options: options)
        postProcessPass.draw(renderEncoder: renderEncoder,
                             cullingResult: cullingResult,
                             uniforms: uniforms,
                             params: params,
                             options: options)
        renderEncoder.endEncoding()
    }
    
}

