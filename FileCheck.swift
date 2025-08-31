import Foundation
import UIKit

class FileCheck {
    static func checkFiles() {
        print("\n=== Checking for required files ===")
        
        // Check level files
        for i in 1...5 {
            let fileName = "level\(i).json"
            if let path = Bundle.main.path(forResource: "level\(i)", ofType: "json") {
                print("✅ Found \(fileName) at: \(path)")
            } else {
                print("❌ Missing \(fileName)")
            }
        }
        
        // Check asset catalog
        let assetsPath = Bundle.main.path(forResource: "Assets", ofType: "car")
        print("\nAsset catalog: \(assetsPath != nil ? "✅ Found" : "❌ Missing")")
        
        // Check for specific assets
        let redCharPath = Bundle.main.path(forResource: "character_red", ofType: "png")
        print("Red character: \(redCharPath != nil ? "✅ Found" : "❌ Missing")")
        
        let blueCharPath = Bundle.main.path(forResource: "character_blue", ofType: "png")
        print("Blue character: \(blueCharPath != nil ? "✅ Found" : "❌ Missing")")
        
        // List all files in the main bundle
        print("\n=== Bundle Contents ===")
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                for item in items {
                    print("📄 \(item)")
                }
            } catch {
                print("❌ Error listing bundle contents: \(error)")
            }
        }
        
        // Check documents directory
        print("\n=== Documents Directory ===")
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("Documents path: \(documentsPath)")
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
                for item in items {
                    print("📄 \(item)")
                }
            } catch {
                print("❌ Error listing documents directory: \(error)")
            }
        }
        
        print("\n=== End of file check ===\n")
    }
}
