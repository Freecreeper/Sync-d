import SpriteKit

class LevelSelectScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupLevelButtons()
    }
    
    private func setupLevelButtons() {
        let levels = LevelManager.shared.getLevels()
        
        for (index, level) in levels.enumerated() {
            let button = SKLabelNode(text: level.name)
            button.name = "level\(level.id)"
            button.position = CGPoint(x: frame.midX, y: frame.midY - CGFloat(index * 60))
            button.fontColor = .white
            addChild(button)
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
        gameScene.currentLevel = levelId
        
        view.presentScene(gameScene)
    }
}
