//
//  SceneJsonDecoder.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/23.
//

import Foundation

struct SceneContent: Codable {
    var name: String
}

enum SceneJson {
    static func loadScene(fileName: String) -> SceneContent {
        guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Couldn't find \(fileName).json in main bundle")
        }
        let data: Data
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't find \(fileName).json in main bundle:\n\(error)")
        }
        var loadedContent: SceneContent
        do {
            let decoder = JSONDecoder()
            let content = try decoder.decode(SceneContent.self, from: data)
            loadedContent = content
        } catch {
            fatalError("Couldn't parse \(fileName) as \(SceneContent.self):\n\(error)")
        }
        return loadedContent
    }
}
