import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let character: UInt32 = 0b1
    static let door: UInt32 = 0b10
    static let button: UInt32 = 0b100
    static let key: UInt32 = 0b1000
    static let hazard: UInt32 = 0b10000
    static let wall: UInt32 = 0b100000
}
