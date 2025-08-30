import Foundation

struct Level {
    let id: Int
    let name: String
    let fileName: String
}

class LevelManager {
    static let shared = LevelManager()
    
    private var levels: [Level] = []
    
    private init() {
        // Initialize with 5 levels
        levels = [
            Level(id: 1, name: "Level 1: The Beginning", fileName: "level1"),
            Level(id: 2, name: "Level 2: Buttons and Doors", fileName: "level2"),
            Level(id: 3, name: "Level 3: Keys and Hazards", fileName: "level3"),
            Level(id: 4, name: "Level 4: Double Buttons", fileName: "level4"),
            Level(id: 5, name: "Level 5: The Gauntlet", fileName: "level5")
        ]
    }
    
    func getLevels() -> [Level] {
        return levels
    }
    
    func loadLevelData(levelId: Int) -> Data? {
        guard let level = levels.first(where: { $0.id == levelId }),
              let path = Bundle.main.path(forResource: level.fileName, ofType: "json") else {
            return nil
        }
        
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            print("Error loading level data: \(error)")
            return nil
        }
    }
}
