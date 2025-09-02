import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player1: UInt32 = 0x1 << 0
    static let player2: UInt32 = 0x1 << 1
    static let obstacle: UInt32 = 0x1 << 2
    static let goal: UInt32 = 0x1 << 3
    static let character: UInt32 = 0x1 << 4
    static let door: UInt32 = 0x1 << 5
    static let key: UInt32 = 0x1 << 6
    static let hazard: UInt32 = 0x1 << 7
    static let wall: UInt32 = 0x1 << 8
    static let button: UInt32 = 0x1 << 9
}
