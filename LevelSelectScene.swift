import SpriteKit

class LevelSelectScene: SKScene {
    
    override func didMove(to view: SKView) {
        print("LevelSelectScene: didMove to view with size: \(view.bounds.size)")
        backgroundColor = .darkGray
        print("LevelSelectScene: Background color set")
        setupLevelButtons()
    }
    
    private func setupLevelButtons() {
        print("LevelSelectScene: Setting up level buttons")
        let levels = LevelManager.shared.getLevels()
        print("LevelSelectScene: Found \(levels.count) levels")
        
        if levels.isEmpty {
            print("LevelSelectScene: No levels found")
            let message = SKLabelNode(text: "No levels found")
            message.position = CGPoint(x: frame.midX, y: frame.midY)
            message.fontColor = .white
            addChild(message)
            return
        }
        
        for (index, level) in levels.enumerated() {
            let button = SKLabelNode(text: level.name)
            button.name = "level\(level.id)"
            button.position = CGPoint(x: frame.midX, y: frame.midY - CGFloat(index * 60))
            button.fontColor = .white
            button.horizontalAlignmentMode = .center
            addChild(button)
            print("LevelSelectScene: Added button for level \(level.id) at \(button.position)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let nodeName = node.name, nodeName.hasPrefix("level") {
                let levelId = Int(nodeName.replacingOccurrences(of: "level", with: "")) ?? 1
                loadGameScene(levelId: levelId)
            }
        }
    }
    
    private func loadGameScene(levelId: Int) {
        guard let view = self.view else { return }
        
        let gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .aspectFill
        LevelManager.shared.currentLevel = levelId  // Use shared LevelManager
        
        view.presentScene(gameScene)
    }
}
