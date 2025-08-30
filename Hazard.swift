import SpriteKit

class Hazard: SKSpriteNode {
    
    init() {
        super.init(texture: nil, color: .red, size: CGSize(width: 40, height: 20))
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.hazard
    }
}
