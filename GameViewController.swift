import UIKit
import SpriteKit
import Foundation

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GameViewController: viewDidLoad started")
        
        // Check for required files
        FileCheck.checkFiles()
        
        if let view = self.view as? SKView {
            print("GameViewController: SKView is valid")
            print("View bounds: \(view.bounds)")
            
            // Create and configure the scene
            let scene = LevelSelectScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            print("GameViewController: Created scene with size: \(scene.size)")
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true // Debug only
            
            print("GameViewController: Scene presented")
        } else {
            print("GameViewController: Failed to get SKView")
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
