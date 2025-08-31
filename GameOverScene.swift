import SpriteKit

class GameOverScene: SKScene {
    
    private let score: Int
    
    init(size: CGSize, score: Int) {
        self.score = score
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Game Over Label
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontColor = .white
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        addChild(gameOverLabel)
        
        // Score Label
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        addChild(scoreLabel)
        
        // Restart Button
        let restartButton = SKLabelNode(text: "Tap to Play Again")
        restartButton.fontColor = .green
        restartButton.fontSize = 28
        restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        restartButton.name = "restart"
        addChild(restartButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        if nodes.contains(where: { $0.name == "restart" }) {
            // Restart the game
            let gameScene = GameScene(size: size)
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
