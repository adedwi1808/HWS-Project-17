//
//  GameScene.swift
//  HWS-Project-17
//
//  Created by Ade Dwi Prayitno on 09/02/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var gameOver: SKSpriteNode = SKSpriteNode(imageNamed: "gameOver")
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver: Bool = false
    
    var totalEnemies: Int = 0
    var timerInterval: Double = 1.0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score : \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        gameOver.name = "gameOverLogo"
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        
        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody?.contactTestBitMask = 1
        player.physicsBody?.categoryBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        startGame()
    }
    
    func startGame() {
        isGameOver = false
        gameOver.isHidden = true
        player.isHidden = false
        player.zRotation = 0
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.position = CGPoint(x: 100, y: 384)
        timerInterval = 1
        gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        score = 0
    }
    
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 2
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        totalEnemies += 1
        
        if totalEnemies % 20 == 0, timerInterval - 0.1 > 0 {
            timerInterval -= 0.1
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            endGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "gameOverLogo" {
                startGame()
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        endGame()
//        explosion.removeFromParent()
    }
    
    func endGame() {
        isGameOver = true
        
        player.isHidden = true
        gameOver.isHidden = false
        
        gameTimer?.invalidate()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
}
