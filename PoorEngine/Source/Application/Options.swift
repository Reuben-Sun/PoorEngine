//
//  Options.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import Foundation

enum RenderChoice: CaseIterable {
    case shadered
    case wireframe
    case albdeo
    
    var name: String{
        switch self{
        case .shadered: return "Shadered"
        case .wireframe: return "Wireframe"
        case .albdeo: return "Albedo"
        }
    }
}

extension RenderChoice: Identifiable{
    var id: Self {self}
}

enum RenderPath: CaseIterable {
    case forward
    case deferred
    case tiled
    
    var name: String{
        switch self{
        case .forward: return "Forward"
        case .deferred: return "Deferred"
        case .tiled: return "Tiled"
        }
    }
}

extension RenderPath: Identifiable{
    var id: Self {self}
}

class Options: ObservableObject {
    @Published var renderChoice = RenderChoice.shadered
    @Published var renderPath = RenderPath.deferred
    @Published var tiledSupported = false
}
