import Foundation
import UIKit

struct LevelData: Codable {
    let id: Int
    let name: String
    let timeLimit: TimeInterval
    let obstacles: [ObstacleData]
    let player1Start: CGPoint
    let player2Start: CGPoint
    let goalPosition: CGPoint
    let requiredScore: Int
    
    struct ObstacleData: Codable {
        let position: CGPoint
        let size: CGSize
        let isHazard: Bool
    }
}

class LevelManager {
    static let shared = LevelManager()
    
    private(set) var currentLevel = 1
    private let totalLevels = 20
    private var completedLevels: Set<Int> = []
    
    private init() {}
    
    func getCurrentLevelData() -> LevelData? {
        return generateLevelData(level: currentLevel)
    }
    
    func advanceToNextLevel() -> Bool {
        guard currentLevel < totalLevels else { return false }
        completedLevels.insert(currentLevel)
        currentLevel += 1
        return true
    }
    
    func resetProgress() {
        currentLevel = 1
        completedLevels.removeAll()
    }
    
    func getLevelProgress() -> (current: Int, total: Int, completed: Int) {
        return (currentLevel, totalLevels, completedLevels.count)
    }
    
    private func generateLevelData(level: Int) -> LevelData {
        // Base values that scale with level
        let baseObstacleCount = 2 + (level / 2)
        let timeDecrease = Double(level) * 2.0
        let baseTimeLimit = max(60.0 - timeDecrease, 30.0) // Don't go below 30 seconds
        
        // Generate random obstacles
        var obstacles: [LevelData.ObstacleData] = []
        for _ in 0..<baseObstacleCount {
            let isHazard = Bool.random() && level > 5 // Only add hazards after level 5
            let size = CGSize(
                width: CGFloat.random(in: 50...150),
                height: CGFloat.random(in: 20...40)
            )
            let position = CGPoint(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
            )
            
            obstacles.append(LevelData.ObstacleData(
                position: position,
                size: size,
                isHazard: isHazard
            ))
        }
        
        // Calculate start positions and goal
        let player1Start = CGPoint(x: 100, y: 100)
        let player2Start = CGPoint(x: UIScreen.main.bounds.width - 100, y: 100)
        let goalPosition = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height - 100
        )
        
        return LevelData(
            id: level,
            name: "Level \(level)",
            timeLimit: baseTimeLimit,
            obstacles: obstacles,
            player1Start: player1Start,
            player2Start: player2Start,
            goalPosition: goalPosition,
            requiredScore: level * 100
        )
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        return level == 1 || completedLevels.contains(level - 1)
    }
    
    func getLevelCompletion(_ level: Int) -> Bool {
        return completedLevels.contains(level)
    }
}
