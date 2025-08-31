import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var characters: [Character] = []
    var activeCharacterIndex = 0
    var currentLevel = 1
    var doors: [Door] = []
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }!
    
    // MARK: - Game Logic
    
    private func gameOver() {
        // Show game over scene
        let gameOverScene = GameOverScene(size: size, score: score)
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: transition)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = .lightGray
        
        // Start background music
        SoundManager.shared.playBackgroundMusic(filename: "background_music.mp3")
        
        setupUI()
        setupPlayers()
        setupObstacles()
    }
    
    private func setupUI() {
        // Score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height - 50)
        scoreLabel.fontColor = .black
        scoreLabel.fontSize = 24
        addChild(scoreLabel)
    }
    
    private func setupPlayers() {
        // Player 1 (Red)
        player1 = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        player1.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        player1.physicsBody = SKPhysicsBody(rectangleOf: player1.size)
        player1.physicsBody?.isDynamic = true
        player1.physicsBody?.affectedByGravity = false
        player1.physicsBody?.categoryBitMask = 0b1
        player1.physicsBody?.contactTestBitMask = 0b100 | 0b1000
        player1.physicsBody?.collisionBitMask = 0
        addChild(player1)
        
        // Player 2 (Blue)
        player2 = SKSpriteNode(color: .blue, size: CGSize(width: 40, height: 40))
        player2.position = CGPoint(x: size.width * 0.7, y: size.height * 0.5)
        player2.physicsBody = SKPhysicsBody(rectangleOf: player2.size)
        player2.physicsBody?.isDynamic = true
        player2.physicsBody?.affectedByGravity = false
        player2.physicsBody?.categoryBitMask = 0b10
        player2.physicsBody?.contactTestBitMask = 0b100 | 0b1000
        player2.physicsBody?.collisionBitMask = 0
        addChild(player2)
    }
    
    private func setupObstacles() {
        // Add some basic obstacles
        let obstacle1 = SKSpriteNode(color: .lightGray, size: CGSize(width: 100, height: 20))
        obstacle1.position = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        obstacle1.physicsBody = SKPhysicsBody(rectangleOf: obstacle1.size)
        obstacle1.physicsBody?.isDynamic = false
        obstacle1.physicsBody?.categoryBitMask = 0b100
        addChild(obstacle1)
        
        // Add a goal
        let goal = SKSpriteNode(color: .green, size: CGSize(width: 60, height: 60))
        goal.position = CGPoint(x: size.width * 0.5, y: 50)
        goal.physicsBody = SKPhysicsBody(rectangleOf: goal.size)
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.categoryBitMask = 0b1000
        addChild(goal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Move player 1
        let moveAction1 = SKAction.move(to: location, duration: 0.5)
        player1.run(moveAction1)
        
        // Move player 2
        let moveAction2 = SKAction.move(to: location, duration: 0.5)
        player2.run(moveAction2)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Check if players reached the goal
        if collision == (0b1 | 0b1000) || collision == (0b10 | 0b1000) {
            score += 10
            
            // Reset positions
            player1.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
            player2.position = CGPoint(x: size.width * 0.7, y: size.height * 0.5)
        // Character-door collision
        if collision == PhysicsCategory.character | PhysicsCategory.door {
            SoundManager.shared.playSoundEffect(filename: "door_open.wav")
            checkLevelCompletion()
        }
        
        // Character-hazard collision
        if collision == PhysicsCategory.character | PhysicsCategory.hazard {
            SoundManager.shared.playSoundEffect(filename: "death.wav")
            loadLevel() // Restart on hazard touch
        }
        
        // Character-key collision
        if collision == PhysicsCategory.character | PhysicsCategory.key {
            SoundManager.shared.playSoundEffect(filename: "key_pickup.wav")
            addScore(points: 50)
        }
        
        // Character-button collision
        if collision == PhysicsCategory.character | PhysicsCategory.button {
            SoundManager.shared.playSoundEffect(filename: "button_press.wav")
            // Handle button press
        }
    }
    
    private func checkLevelCompletion() {
        // Check if all characters reached the door
        // TODO: Implement actual completion check
        
        // For now, just advance to next level
        addScore(points: timeRemaining * 10)
        currentLevel += 1
        loadLevel()
    }
}
