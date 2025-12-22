import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
  private enum Category {
    static let player: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let roach: UInt32 = 0x1 << 2
    static let collectible: UInt32 = 0x1 << 3
    static let goal: UInt32 = 0x1 << 4
  }

  private enum GameState {
    case menu
    case playing
    case gameOver
    case levelComplete
  }

  private let player = SKSpriteNode()
  private let cameraNode = SKCameraNode()
  private let hudNode = SKNode()
  private let uiNode = SKNode()
  private let backgroundNode = SKSpriteNode(imageNamed: "background")

  private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
  private var meterLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
  private var meterBar = SKShapeNode()
  private var meterFill = SKShapeNode()

  private var moveLeft = false
  private var moveRight = false
  private var jumpRequested = false

  private var state: GameState = .menu
  private var score = 0
  private var meter: CGFloat = 0.7
  private var lastUpdate: TimeInterval = 0

  override func didMove(to view: SKView) {
    physicsWorld.contactDelegate = self
    setupScene()
    showMenu()
  }

  private func setupScene() {
    backgroundColor = SKColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
    camera = cameraNode
    addChild(cameraNode)
    cameraNode.addChild(backgroundNode)
    backgroundNode.position = CGPoint(x: 0, y: size.height * 0.1)
    backgroundNode.size = CGSize(width: size.width * 1.2, height: size.height)

    cameraNode.addChild(hudNode)
    cameraNode.addChild(uiNode)
    setupHud()
    setupControls()

    spawnPlayer()
    spawnLevel()
  }

  private func setupHud() {
    scoreLabel.fontSize = 24
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.position = CGPoint(x: -size.width / 2 + 40, y: size.height / 2 - 50)
    hudNode.addChild(scoreLabel)

    meterLabel.fontSize = 18
    meterLabel.horizontalAlignmentMode = .left
    meterLabel.position = CGPoint(x: -size.width / 2 + 40, y: size.height / 2 - 85)
    hudNode.addChild(meterLabel)

    let barWidth: CGFloat = 160
    let barHeight: CGFloat = 12
    meterBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
    meterBar.strokeColor = .white
    meterBar.lineWidth = 2
    meterBar.position = CGPoint(x: -size.width / 2 + 120, y: size.height / 2 - 110)
    hudNode.addChild(meterBar)

    meterFill = SKShapeNode(rectOf: CGSize(width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
    meterFill.fillColor = .green
    meterFill.strokeColor = .clear
    meterFill.position = CGPoint(x: 0, y: 0)
    meterBar.addChild(meterFill)

    updateHud()
  }

  private func setupControls() {
    let left = makeButton(label: "◀︎", name: "left", position: CGPoint(x: -size.width / 2 + 80, y: -size.height / 2 + 70))
    let right = makeButton(label: "▶︎", name: "right", position: CGPoint(x: -size.width / 2 + 160, y: -size.height / 2 + 70))
    let jump = makeButton(label: "⤒", name: "jump", position: CGPoint(x: size.width / 2 - 100, y: -size.height / 2 + 70))
    uiNode.addChild(left)
    uiNode.addChild(right)
    uiNode.addChild(jump)
  }

  private func makeButton(label: String, name: String, position: CGPoint) -> SKSpriteNode {
    let button = SKSpriteNode(color: SKColor(white: 0.1, alpha: 0.7), size: CGSize(width: 70, height: 60))
    button.name = name
    button.position = position
    button.zPosition = 100
    button.alpha = 0.8
    button.isUserInteractionEnabled = false
    let text = SKLabelNode(fontNamed: "AvenirNext-Bold")
    text.text = label
    text.fontSize = 26
    text.verticalAlignmentMode = .center
    text.position = .zero
    button.addChild(text)
    return button
  }

  private func spawnPlayer() {
    player.texture = SKTexture(imageNamed: "player")
    player.size = CGSize(width: 48, height: 72)
    player.position = CGPoint(x: 120, y: 200)
    player.name = "player"
    player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.categoryBitMask = Category.player
    player.physicsBody?.collisionBitMask = Category.ground
    player.physicsBody?.contactTestBitMask = Category.roach | Category.collectible | Category.goal
    addChild(player)
  }

  private func spawnLevel() {
    spawnGround()
    spawnStoops()
    spawnCollectibles()
    spawnRoaches()
    spawnGoal()
  }

  private func spawnGround() {
    let ground = SKSpriteNode(imageNamed: "ground")
    ground.size = CGSize(width: 2600, height: 60)
    ground.position = CGPoint(x: 1300, y: 80)
    ground.name = "ground"
    ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
    ground.physicsBody?.isDynamic = false
    ground.physicsBody?.categoryBitMask = Category.ground
    addChild(ground)
  }

  private func spawnStoops() {
    let positions = [
      CGPoint(x: 360, y: 140),
      CGPoint(x: 640, y: 190),
      CGPoint(x: 980, y: 170),
      CGPoint(x: 1280, y: 220),
      CGPoint(x: 1680, y: 160)
    ]
    for point in positions {
      let stoop = SKSpriteNode(imageNamed: "stoop")
      stoop.size = CGSize(width: 160, height: 110)
      stoop.position = point
      stoop.physicsBody = SKPhysicsBody(rectangleOf: stoop.size)
      stoop.physicsBody?.isDynamic = false
      stoop.physicsBody?.categoryBitMask = Category.ground
      addChild(stoop)
    }
  }

  private func spawnCollectibles() {
    let points = [
      CGPoint(x: 420, y: 240),
      CGPoint(x: 700, y: 280),
      CGPoint(x: 900, y: 220),
      CGPoint(x: 1160, y: 300),
      CGPoint(x: 1500, y: 240),
      CGPoint(x: 1820, y: 260)
    ]
    for point in points {
      let item = SKSpriteNode(imageNamed: "collectible")
      item.size = CGSize(width: 24, height: 42)
      item.position = point
      item.name = "collectible"
      item.physicsBody = SKPhysicsBody(rectangleOf: item.size)
      item.physicsBody?.isDynamic = false
      item.physicsBody?.categoryBitMask = Category.collectible
      item.physicsBody?.contactTestBitMask = Category.player
      addChild(item)
    }
  }

  private func spawnRoaches() {
    let points = [
      CGPoint(x: 520, y: 120),
      CGPoint(x: 860, y: 120),
      CGPoint(x: 1220, y: 120),
      CGPoint(x: 1540, y: 120),
      CGPoint(x: 1900, y: 120)
    ]
    for point in points {
      let roach = SKSpriteNode(imageNamed: "roach")
      roach.size = CGSize(width: 48, height: 28)
      roach.position = point
      roach.name = "roach"
      roach.physicsBody = SKPhysicsBody(rectangleOf: roach.size)
      roach.physicsBody?.isDynamic = false
      roach.physicsBody?.categoryBitMask = Category.roach
      roach.physicsBody?.contactTestBitMask = Category.player
      addChild(roach)
      let move = SKAction.sequence([
        SKAction.moveBy(x: 60, y: 0, duration: 1.2),
        SKAction.moveBy(x: -60, y: 0, duration: 1.2)
      ])
      roach.run(SKAction.repeatForever(move))
    }
  }

  private func spawnGoal() {
    let goal = SKSpriteNode(color: .yellow, size: CGSize(width: 40, height: 100))
    goal.position = CGPoint(x: 2300, y: 150)
    goal.name = "goal"
    goal.physicsBody = SKPhysicsBody(rectangleOf: goal.size)
    goal.physicsBody?.isDynamic = false
    goal.physicsBody?.categoryBitMask = Category.goal
    goal.physicsBody?.contactTestBitMask = Category.player
    addChild(goal)
  }

  private func showMenu() {
    state = .menu
    uiNode.removeAllChildren()
    setupControls()
    let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
    title.text = "Stoop Runner"
    title.fontSize = 42
    title.position = CGPoint(x: 0, y: 60)
    title.zPosition = 200
    uiNode.addChild(title)

    let start = makeMenuButton(text: "Start Game", name: "start", position: CGPoint(x: 0, y: 0))
    let settings = makeMenuButton(text: "Settings", name: "settings", position: CGPoint(x: 0, y: -60))
    uiNode.addChild(start)
    uiNode.addChild(settings)
  }

  private func showGameOver() {
    state = .gameOver
    uiNode.removeAllChildren()
    let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
    label.text = "Game Over"
    label.fontSize = 36
    label.position = CGPoint(x: 0, y: 40)
    uiNode.addChild(label)

    let scoreNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
    scoreNode.text = "Score: \(score)"
    scoreNode.fontSize = 22
    scoreNode.position = CGPoint(x: 0, y: 0)
    uiNode.addChild(scoreNode)

    let restart = makeMenuButton(text: "Restart Level", name: "restart", position: CGPoint(x: 0, y: -60))
    uiNode.addChild(restart)
  }

  private func showLevelComplete() {
    state = .levelComplete
    uiNode.removeAllChildren()
    let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
    label.text = "Level Complete"
    label.fontSize = 34
    label.position = CGPoint(x: 0, y: 40)
    uiNode.addChild(label)

    let scoreNode = SKLabelNode(fontNamed: "AvenirNext-Regular")
    scoreNode.text = "Score: \(score)"
    scoreNode.fontSize = 22
    scoreNode.position = CGPoint(x: 0, y: 0)
    uiNode.addChild(scoreNode)

    let restart = makeMenuButton(text: "Restart Level", name: "restart", position: CGPoint(x: 0, y: -60))
    let next = makeMenuButton(text: "Next Level", name: "next", position: CGPoint(x: 0, y: -120))
    uiNode.addChild(restart)
    uiNode.addChild(next)
  }

  private func makeMenuButton(text: String, name: String, position: CGPoint) -> SKSpriteNode {
    let button = SKSpriteNode(color: SKColor(white: 0.15, alpha: 0.8), size: CGSize(width: 220, height: 48))
    button.name = name
    button.position = position
    button.zPosition = 200
    let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
    label.text = text
    label.fontSize = 20
    label.verticalAlignmentMode = .center
    label.position = .zero
    button.addChild(label)
    return button
  }

  private func startGame() {
    score = 0
    meter = 0.7
    updateHud()
    state = .playing
    uiNode.removeAllChildren()
    setupControls()
  }

  private func resetScene() {
    let newScene = GameScene(size: size)
    newScene.scaleMode = scaleMode
    view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
  }

  private func updateHud() {
    scoreLabel.text = "Score: \(score)"
    meterLabel.text = "Meter"
    let maxWidth = meterBar.frame.width - 4
    let width = max(0, maxWidth * meter)
    meterFill.path = CGPath(roundedRect: CGRect(x: -maxWidth / 2, y: -(meterBar.frame.height - 4) / 2, width: width, height: meterBar.frame.height - 4), cornerWidth: 3, cornerHeight: 3, transform: nil)
    meterFill.position = CGPoint(x: -maxWidth / 2 + width / 2, y: 0)
    meterFill.fillColor = meter > 0.3 ? .green : .red
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: cameraNode)
    let nodes = cameraNode.nodes(at: location)
    for node in nodes {
      guard let name = node.name ?? node.parent?.name else { continue }
      switch name {
      case "left":
        moveLeft = true
      case "right":
        moveRight = true
      case "jump":
        jumpRequested = true
      case "start":
        startGame()
      case "restart":
        resetScene()
      case "next":
        resetScene()
      case "settings":
        showSettingsToast()
      default:
        break
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    moveLeft = false
    moveRight = false
  }

  private func showSettingsToast() {
    let toast = SKLabelNode(fontNamed: "AvenirNext-Regular")
    toast.text = "Coming Soon"
    toast.fontSize = 18
    toast.position = CGPoint(x: 0, y: -110)
    toast.alpha = 0
    uiNode.addChild(toast)
    toast.run(SKAction.sequence([
      SKAction.fadeIn(withDuration: 0.2),
      SKAction.wait(forDuration: 1.0),
      SKAction.fadeOut(withDuration: 0.2),
      SKAction.removeFromParent()
    ]))
  }

  override func update(_ currentTime: TimeInterval) {
    guard state == .playing else { return }
    let delta = currentTime - lastUpdate
    lastUpdate = currentTime

    let moveSpeed: CGFloat = 160
    var velocity = player.physicsBody?.velocity ?? .zero
    if moveLeft {
      velocity.dx = -moveSpeed
    } else if moveRight {
      velocity.dx = moveSpeed
    } else {
      velocity.dx = 0
    }
    player.physicsBody?.velocity = velocity

    if jumpRequested, let body = player.physicsBody, abs(body.velocity.dy) < 0.1 {
      body.applyImpulse(CGVector(dx: 0, dy: 320))
    }
    jumpRequested = false

    meter = max(0, meter - CGFloat(delta) * 0.02)
    updateHud()
    if meter == 0 {
      showGameOver()
    }

    cameraNode.position = CGPoint(x: player.position.x, y: size.height / 2)
  }

  func didBegin(_ contact: SKPhysicsContact) {
    guard state == .playing, let a = contact.bodyA.node, let b = contact.bodyB.node else { return }
    let names = [a.name, b.name]
    if names.contains("collectible") && names.contains("player") {
      let item = (a.name == "collectible") ? a : b
      item.removeFromParent()
      meter = min(1.0, meter + 0.2)
      updateHud()
      return
    }

    if names.contains("roach") && names.contains("player") {
      let roach = (a.name == "roach") ? a : b
      if player.position.y > roach.position.y + roach.frame.height * 0.3,
         (player.physicsBody?.velocity.dy ?? 0) < 0 {
        roach.removeFromParent()
        score += 10
        updateHud()
      } else {
        showGameOver()
      }
      return
    }

    if names.contains("goal") && names.contains("player") {
      showLevelComplete()
    }
  }
}
