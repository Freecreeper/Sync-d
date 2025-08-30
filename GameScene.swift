import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var characters: [Character] = []
    var activeCharacterIndex = 0
    var currentLevel = 1
    var doors: [Door] = []
    var buttons: [Button] = []
    var keys: [Key] = []
    var hazards: [Hazard] = []
    var exitNode: SKSpriteNode?
    var score = 0
    var levelTimer: Timer?
    var timeRemaining = 60
    var timerLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = .lightGray
        
        // Start background music
        SoundManager.shared.playBackgroundMusic(filename: "background_music.mp3")
        
        setupUI()
        startTimer()
        loadLevel()
    }
    
    private func setupUI() {
        // Timer label
        timerLabel = SKLabelNode(text: "Time: \(timeRemaining)")
        timerLabel.position = CGPoint(x: frame.minX + 100, y: frame.maxY - 30)
        timerLabel.fontColor = .black
        addChild(timerLabel)
        
        // Score label
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 30)
        scoreLabel.fontColor = .black
        addChild(scoreLabel)
    }
    
    private func startTimer() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.timerLabel.text = "Time: \(self.timeRemaining)"
            
            if self.timeRemaining <= 0 {
                self.levelTimer?.invalidate()
                self.loadLevel() // Restart level on timeout
            }
        }
    }
    
    private func addScore(points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }
    
    private func loadLevel() {
        // Clear existing nodes
        removeAllChildren()
        characters.removeAll()
        doors.removeAll()
        buttons.removeAll()
        keys.removeAll()
        hazards.removeAll()
        exitNode = nil
        
        // Load level data
        guard let levelData = LevelManager.shared.loadLevelData(levelId: currentLevel),
              let levelJson = try? JSONSerialization.jsonObject(with: levelData, options: []) as? [String: Any] else {
            setupDefaultLevel()
            return
        }
        
        // Create walls
        if let walls = levelJson["walls"] as? [[String: Any]] {
            for wall in walls {
                createWall(from: wall)
            }
        }
        
        // Create characters
        if let charactersJson = levelJson["characters"] as? [[String: Any]] {
            for charJson in charactersJson {
                createCharacter(from: charJson)
            }
        }
        
        // Create exit
        if let exitJson = levelJson["exit"] as? [String: Any] {
            createExit(from: exitJson)
        }
        
        // Create buttons and doors
        if let buttonsJson = levelJson["buttons"] as? [[String: Any]] {
            for buttonJson in buttonsJson {
                createButton(from: buttonJson)
            }
        }
        
        if let doorsJson = levelJson["doors"] as? [[String: Any]] {
            for doorJson in doorsJson {
                createDoor(from: doorJson)
            }
        }
        
        // Create keys
        if let keysJson = levelJson["keys"] as? [[String: Any]] {
            for keyJson in keysJson {
                createKey(from: keyJson)
            }
        }
        
        // Create hazards
        if let hazardsJson = levelJson["hazards"] as? [[String: Any]] {
            for hazardJson in hazardsJson {
                createHazard(from: hazardJson)
            }
        }
        
        // Set first character active
        switchActiveCharacter(to: 0)
        
        // Add restart button
        addRestartButton()
    }
    
    private func createWall(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let width = json["width"] as? CGFloat,
              let height = json["height"] as? CGFloat else { return }
        
        let wall = SKSpriteNode(color: .black, size: CGSize(width: width, height: height))
        wall.position = CGPoint(x: x, y: y)
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(wall)
    }
    
    private func createCharacter(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let colorName = json["color"] as? String else { return }
        
        let color: UIColor
        switch colorName {
        case "red": color = .red
        case "blue": color = .blue
        case "green": color = .green
        default: color = .red
        }
        
        let character = Character(color: color, size: CGSize(width: 30, height: 30))
        character.position = CGPoint(x: x, y: y)
        addChild(character)
        characters.append(character)
    }
    
    private func createExit(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat else { return }
        
        let exit = SKSpriteNode(color: .green, size: CGSize(width: 40, height: 60))
        exit.position = CGPoint(x: x, y: y)
        exit.physicsBody = SKPhysicsBody(rectangleOf: exit.size)
        exit.physicsBody?.isDynamic = false
        exit.physicsBody?.categoryBitMask = PhysicsCategory.door
        exit.name = "exit"
        addChild(exit)
        exitNode = exit
    }
    
    private func createButton(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let doorId = json["linkedDoorId"] as? Int else { return }
        
        let button = Button()
        button.position = CGPoint(x: x, y: y)
        addChild(button)
        buttons.append(button)
        
        // Link to door (will be set when door is created)
        button.linkedDoor = doors.first(where: { $0.doorId == doorId })
    }
    
    private func createDoor(from json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let width = json["width"] as? CGFloat,
              let height = json["height"] as? CGFloat else { return }
        
        let door = Door()
        door.doorId = id
        door.size = CGSize(width: width, height: height)
        door.position = CGPoint(x: x, y: y)
        addChild(door)
        doors.append(door)
    }
    
    private func createKey(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let doorId = json["linkedDoorId"] as? Int else { return }
        
        let key = Key()
        key.position = CGPoint(x: x, y: y)
        key.doorToUnlock = doors.first(where: { $0.doorId == doorId })
        addChild(key)
        keys.append(key)
    }
    
    private func createHazard(from json: [String: Any]) {
        guard let x = json["x"] as? CGFloat,
              let y = json["y"] as? CGFloat,
              let width = json["width"] as? CGFloat,
              let height = json["height"] as? CGFloat else { return }
        
        let hazard = Hazard()
        hazard.size = CGSize(width: width, height: height)
        hazard.position = CGPoint(x: x, y: y)
        addChild(hazard)
        hazards.append(hazard)
    }
    
    private func switchActiveCharacter(to index: Int) {
        characters[activeCharacterIndex].isActive = false
        activeCharacterIndex = index
        characters[activeCharacterIndex].isActive = true
    }
    
    private func addRestartButton() {
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        restartButton.fontColor = .black
        addChild(restartButton)
    }
    
    private func setupDefaultLevel() {
        // Create a simple default level with walls around the edges
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let wallSize: CGFloat = 40
        
        // Create boundary walls
        let horizontalWallSize = CGSize(width: screenWidth, height: wallSize)
        let verticalWallSize = CGSize(width: wallSize, height: screenHeight)
        
        // Top wall
        createWall(at: CGPoint(x: screenWidth/2, y: screenHeight - wallSize/2), size: horizontalWallSize)
        // Bottom wall
        createWall(at: CGPoint(x: screenWidth/2, y: wallSize/2), size: horizontalWallSize)
        // Left wall
        createWall(at: CGPoint(x: wallSize/2, y: screenHeight/2), size: verticalWallSize)
        // Right wall
        createWall(at: CGPoint(x: screenWidth - wallSize/2, y: screenHeight/2), size: verticalWallSize)
        
        // Add a default character
        let character = Character(color: .blue, size: CGSize(width: 30, height: 30))
        character.position = CGPoint(x: screenWidth/2, y: screenHeight/2)
        addChild(character)
        characters.append(character)
        
        // Add an exit
        let exit = SKSpriteNode(color: .green, size: CGSize(width: 40, height: 40))
        exit.position = CGPoint(x: screenWidth - 100, y: 100)
        exit.name = "exit"
        exit.physicsBody = SKPhysicsBody(rectangleOf: exit.size)
        exit.physicsBody?.isDynamic = false
        exit.physicsBody?.categoryBitMask = 0x1 << 2 // Exit category
        addChild(exit)
        exitNode = exit
    }
    
    private func createWall(at position: CGPoint, size: CGSize) {
        let wall = SKSpriteNode(color: .brown, size: size)
        wall.position = position
        wall.physicsBody = SKPhysicsBody(rectangleOf: size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = 0x1 << 1 // Wall category
        addChild(wall)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check for restart button tap
        if let node = nodes(at: location).first, node.name == "restartButton" {
            loadLevel()
            return
        }
        
        // Check for character selection
        for (index, character) in characters.enumerated() {
            if character.contains(location) {
                switchActiveCharacter(to: index)
                SoundManager.shared.playSoundEffect(filename: "character_switch.wav")
                return
            }
        }
        
        // Move active character
        let moveAction = SKAction.move(to: location, duration: 0.5)
        characters[activeCharacterIndex].run(moveAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
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
