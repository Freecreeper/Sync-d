import SpriteKit

class Button: SKSpriteNode {
    var linkedDoor: Door?
    var isPressed = false
    
    init() {
        super.init(texture: nil, color: .gray, size: CGSize(width: 40, height: 20))
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.button
    }
    
    func press() {
        isPressed = true
        color = .green
        linkedDoor?.open()
    }
    
    func release() {
        isPressed = false
        color = .gray
        linkedDoor?.close()
    }
}

class Door: SKSpriteNode {
    var doorId: Int = 0
    var isOpen = false
    
    init() {
        super.init(texture: nil, color: .brown, size: CGSize(width: 40, height: 60))
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.door
    }
    
    func open() {
        isOpen = true
        color = .yellow
        physicsBody?.categoryBitMask = PhysicsCategory.none
    }
    
    func close() {
        isOpen = false
        color = .brown
        physicsBody?.categoryBitMask = PhysicsCategory.door
    }
}
