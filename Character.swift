import SpriteKit

class Character: SKSpriteNode {
    var isActive = false
    
    init(color: UIColor, size: CGSize) {
        let textureName: String
        switch color {
        case .red: textureName = "character_red"
        case .blue: textureName = "character_blue"
        default: textureName = "character_red"
        }
        
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: size)
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.character
        physicsBody?.contactTestBitMask = PhysicsCategory.door | PhysicsCategory.key | PhysicsCategory.hazard
    }
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let character: UInt32 = 0b1
    static let door: UInt32 = 0b10
    static let button: UInt32 = 0b100
    static let key: UInt32 = 0b1000
    static let hazard: UInt32 = 0b10000
    static let wall: UInt32 = 0b100000
}
