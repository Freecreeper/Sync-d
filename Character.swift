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
