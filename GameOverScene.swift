import SpriteKit

class GameOverScene: SKScene {
    
    private let score: Int
    private let isGameComplete: Bool
    
    init(size: CGSize, score: Int, isGameComplete: Bool = false) {
        self.score = score
        self.isGameComplete = isGameComplete
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Title Label
        let titleText = isGameComplete ? "You Win!" : "Game Over"
        let gameOverLabel = SKLabelNode(text: titleText)
        gameOverLabel.fontColor = isGameComplete ? .green : .white
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        addChild(gameOverLabel)
        
        // Score Label
        let scoreLabel = SKLabelNode(text: "Final Score: \(score)")
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        addChild(scoreLabel)
        
        // High Score
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            let highScoreLabel = SKLabelNode(text: "New High Score!")
            highScoreLabel.fontColor = .yellow
            highScoreLabel.fontSize = 28
            highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
            addChild(highScoreLabel)
        } else {
            let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
            highScoreLabel.fontColor = .lightGray
            highScoreLabel.fontSize = 24
            highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
            addChild(highScoreLabel)
        }
        
        // Restart Button
        let buttonText = isGameComplete ? "Play Again" : "Try Again"
        let restartButton = SKLabelNode(text: buttonText)
        restartButton.fontColor = .green
        restartButton.fontSize = 28
        restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        restartButton.name = "restart"
        addChild(restartButton)
        
        // Menu Button
        let menuButton = SKLabelNode(text: "Main Menu")
        menuButton.fontColor = .blue
        menuButton.fontSize = 24
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        menuButton.name = "menu"
        addChild(menuButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        if let node = nodes.first {
            switch node.name {
            case "restart":
                // Restart the game
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
                
            case "menu":
                // Go to main menu
                if let view = view {
                    let menuScene = MainMenuScene(size: size)
                    menuScene.scaleMode = .aspectFill
                    view.presentScene(menuScene, transition: .fade(withDuration: 0.5))
                }
                
            default:
                break
            }
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
