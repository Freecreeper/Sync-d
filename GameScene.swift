import SpriteKit
import AVFoundation

// Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player1: UInt32 = 0b1
    static let player2: UInt32 = 0b10
    static let obstacle: UInt32 = 0b100
    static let goal: UInt32 = 0b1000
    static let hazard: UInt32 = 0b10000
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player1: UInt32 = 0b1
    static let player2: UInt32 = 0b10
    static let obstacle: UInt32 = 0b100
    static let goal: UInt32 = 0b1000
    static let hazard: UInt32 = 0b10000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Game elements
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var goal: SKSpriteNode!
    var obstacles: [SKSpriteNode] = []
    var hazards: [SKSpriteNode] = []
    
    // UI Elements
    var scoreLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    
    // Game state
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var timeRemaining: TimeInterval = 60.0
    var gameTimer: Timer?
    var levelComplete = false
    
    // MARK: - Game State
    private var currentLevel = 1
    
    private func gameOver() {
        gameTimer?.invalidate()
        let gameOverScene = GameOverScene(size: size, score: score, isGameComplete: false)
        view?.presentScene(gameOverScene, transition: .fade(withDuration: 0.5))
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        // Start background music
        SoundManager.shared.playBackgroundMusic(filename: "background_music.mp3")
        
        setupUI()
        loadCurrentLevel()
    }
    
    private func setupUI() {
        // Score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: size.height - 50)
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 24
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // Level label
        levelLabel = SKLabelNode(text: "Level: 1")
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        levelLabel.fontColor = .white
        levelLabel.fontSize = 24
        addChild(levelLabel)
        
        // Time label
        timeLabel = SKLabelNode(text: "Time: 60")
        timeLabel.position = CGPoint(x: size.width - 100, y: size.height - 50)
        timeLabel.fontColor = .white
        timeLabel.fontSize = 24
        timeLabel.horizontalAlignmentMode = .right
        addChild(timeLabel)
    }
    
    private func loadCurrentLevel() {
        // Clean up previous level
        removeAllChildren()
        obstacles.removeAll()
        hazards.removeAll()
        
        // Reset game state
        levelComplete = false
        
        // Get level data
        guard let levelData = LevelManager.shared.getCurrentLevelData() else {
            // If no level data, show game complete
            showGameComplete()
            return
        }
        
        // Update UI
        levelLabel.text = levelData.name
        timeRemaining = levelData.timeLimit
        
        // Setup players
        setupPlayers(start1: levelData.player1Start, start2: levelData.player2Start)
        
        // Setup goal
        setupGoal(at: levelData.goalPosition)
        
        // Setup obstacles and hazards
        for obstacleData in levelData.obstacles {
            if obstacleData.isHazard {
                createHazard(at: obstacleData.position, size: obstacleData.size)
            } else {
                createObstacle(at: obstacleData.position, size: obstacleData.size)
            }
        }
        
        // Start game timer
        startGameTimer()
    }
    
    private func setupPlayers(start1: CGPoint, start2: CGPoint) {
        // Player 1 (Red)
        player1 = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        player1.position = start1
        player1.physicsBody = SKPhysicsBody(rectangleOf: player1.size)
        player1.physicsBody?.isDynamic = true
        player1.physicsBody?.affectedByGravity = false
        player1.physicsBody?.categoryBitMask = PhysicsCategory.player1
        player1.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.goal | PhysicsCategory.hazard
        player1.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(player1)
        
        // Player 2 (Blue)
        player2 = SKSpriteNode(color: .blue, size: CGSize(width: 40, height: 40))
        player2.position = start2
        player2.physicsBody = SKPhysicsBody(rectangleOf: player2.size)
        player2.physicsBody?.isDynamic = true
        player2.physicsBody?.affectedByGravity = false
        player2.physicsBody?.categoryBitMask = PhysicsCategory.player2
        player2.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.goal | PhysicsCategory.hazard
        player2.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(player2)
    }
    
    private func setupGoal(at position: CGPoint) {
        goal = SKSpriteNode(color: .green, size: CGSize(width: 40, height: 40))
        goal.position = position
        goal.physicsBody = SKPhysicsBody(rectangleOf: goal.size)
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.categoryBitMask = PhysicsCategory.goal
        goal.physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        goal.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(goal)
    }
    
    private func createObstacle(at position: CGPoint, size: CGSize) {
        let obstacle = SKSpriteNode(color: .lightGray, size: size)
        obstacle.position = position
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func createHazard(at position: CGPoint, size: CGSize) {
        let hazard = SKSpriteNode(color: .red, size: size)
        hazard.position = position
        hazard.physicsBody = SKPhysicsBody(rectangleOf: size)
        hazard.physicsBody?.isDynamic = false
        hazard.physicsBody?.categoryBitMask = PhysicsCategory.hazard
        hazard.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(hazard)
        hazards.append(hazard)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !levelComplete, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Move player 1 to touch location
        let moveAction1 = SKAction.move(to: location, duration: 0.3)
        moveAction1.timingMode = .easeOut
        player1.run(moveAction1)
        
        // Move player 2 to mirrored position
        let mirroredX = size.width - location.x
        let mirroredLocation = CGPoint(x: mirroredX, y: location.y)
        let moveAction2 = SKAction.move(to: mirroredLocation, duration: 0.3)
        moveAction2.timingMode = .easeOut
        player2.run(moveAction2)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Check if players reached the goal
        if collision == (PhysicsCategory.player1 | PhysicsCategory.goal) || 
           collision == (PhysicsCategory.player2 | PhysicsCategory.goal) {
            checkLevelCompletion()
        }
            
        // Check for hazard collision
        if collision == (PhysicsCategory.player1 | PhysicsCategory.hazard) || 
           collision == (PhysicsCategory.player2 | PhysicsCategory.hazard) {
            // Restart level on hazard touch
            SoundManager.shared.playSoundEffect(filename: "death.wav")
            loadCurrentLevel()
        }
    }
        
    private func checkLevelCompletion() {
        guard !levelComplete else { return }
        
        // Check if both players reached the goal
        let player1InGoal = player1.frame.intersects(goal.frame)
        let player2InGoal = player2.frame.intersects(goal.frame)
        
        if player1InGoal && player2InGoal {
            levelComplete = true
            
            // Calculate score bonus based on time remaining
            let timeBonus = Int(timeRemaining) * 10
            score += timeBonus + 100 // Base 100 points + time bonus
            
            // Show level complete message
            showLevelComplete()
            
            // Load next level after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.loadNextLevel()
            }
        }
    }
    
    private func loadNextLevel() {
        currentLevel += 1
        loadCurrentLevel()
    }
    
    private func showLevelComplete() {
        let levelLabel = SKLabelNode(text: "Level Complete!")
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelLabel.fontSize = 36
        levelLabel.fontColor = .white
        levelLabel.zPosition = 100
        addChild(levelLabel)
        
        // Animate the label
        levelLabel.setScale(0.1)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        levelLabel.run(sequence) {
            levelLabel.removeFromParent()
        }
    }
    
    private func showGameComplete() {
        let gameOverScene = GameOverScene(size: size, score: score, isGameComplete: true)
        view?.presentScene(gameOverScene, transition: .fade(withDuration: 0.5))
    }
    }

