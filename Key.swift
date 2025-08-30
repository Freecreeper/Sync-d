import SpriteKit

class Key: SKSpriteNode {
    var doorToUnlock: Door?
    
    init() {
        super.init(texture: nil, color: .yellow, size: CGSize(width: 20, height: 20))
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.key
    }
    
    func unlockDoor() {
        doorToUnlock?.open()
        removeFromParent()
    }
}
