//
//  SceneView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import SwiftUI
import MetalKit

struct SceneView: View {
    let options: Options
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    @State private var previousTranslation = CGSize.zero
    @State private var previousScroll: CGFloat = 1
    
    var body: some View {
        GeometryReader{
            gp in
            VStack {
                MetalViewRepresentable(
                    renderer: renderer,
                    metalView: $metalView,
                    options: options)
                .onAppear {
                    renderer = Renderer(
                        metalView: metalView,
                        options: options)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let rect = gp.frame(in: .local)
                        if rect.contains(value.location){
                            InputController.shared.touchLocation = value.location
                            InputController.shared.touchDelta = CGSize(
                                width: value.translation.width - previousTranslation.width,
                                height: value.translation.height - previousTranslation.height)
                            previousTranslation = value.translation
                            // if the user drags, cancel the tap touch
                            if abs(value.translation.width) > 1 ||
                                abs(value.translation.height) > 1 {
                                InputController.shared.touchLocation = nil
                            }
                        }
                    }
                    .onEnded {_ in
                        previousTranslation = .zero
                    })
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        //TODO: 滚轮缩放有问题，后退有距离限制，不清楚是否是设备问题
                        let scroll = value - previousScroll
                        InputController.shared.mouseScroll.x = Float(scroll) * Settings.touchZoomSensitivity
                        previousScroll = value
                    }
                    .onEnded {_ in
                        previousScroll = 1
                    })
            }
        }
    }
    
#if os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
#endif
    
    struct MetalViewRepresentable: ViewRepresentable {
        let renderer: Renderer?
        @Binding var metalView: MTKView
        let options: Options
        
#if os(macOS)
        func makeNSView(context: Context) -> some NSView {
            return metalView
        }
        func updateNSView(_ uiView: NSViewType, context: Context) {
            updateMetalView()
        }
#elseif os(iOS)
        func makeUIView(context: Context) -> MTKView {
            metalView
        }
        
        func updateUIView(_ uiView: MTKView, context: Context) {
            updateMetalView()
        }
#endif
        
        func updateMetalView() {
            renderer?.options = options
            //renderer?.rhi.resetRenderPass(metalView: metalView, options: options)
        }
    }
    
    struct SceneView_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                SceneView(options: Options())
                Text("Metal View")
            }
        }
    }
}
