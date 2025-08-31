import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Game Title
        let titleLabel = SKLabelNode(text: "SYNC")
        titleLabel.fontColor = .white
        titleLabel.fontSize = 72
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // Play Button
        let playButton = SKLabelNode(text: "Play")
        playButton.fontColor = .green
        playButton.fontSize = 36
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        playButton.name = "play"
        addChild(playButton)
        
        // High Score
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontColor = .lightGray
        highScoreLabel.fontSize = 24
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(highScoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "play" {
                // Start the game
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
                break
            }
        }
    }
}
