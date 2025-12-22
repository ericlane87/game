import UIKit
import SpriteKit

final class GameViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let skView = view as? SKView else { return }
    let scene = GameScene(size: view.bounds.size)
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
  }
}
