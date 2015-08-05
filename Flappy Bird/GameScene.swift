//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Hana Lee on 2015. 8. 5..
//  Copyright (c) 2015년 Hana Lee. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score:Int = 0
    var scoreLabel:SKLabelNode = SKLabelNode()
    var gameOverLabel:SKLabelNode = SKLabelNode()
    
    var bird:SKSpriteNode = SKSpriteNode()
    var bg:SKSpriteNode = SKSpriteNode()
    var labelHolder:SKSpriteNode = SKSpriteNode()
    
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 0 << 3
    
    var gameOver = 0
    
    var movingObjects:SKNode = SKNode()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.addChild(movingObjects)
        
        makeBackground()
        
        self.addChild(labelHolder)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        self.addChild(scoreLabel)
        
        var birdTexture:SKTexture = SKTexture(imageNamed: "flappy1.png")
        var birdTexture2:SKTexture = SKTexture(imageNamed: "flappy2.png")
        
        var animation:SKAction = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        var makeBirdFlap:SKAction = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = gapGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        bird.zPosition = 10
        self.addChild(bird)
        
        var groundNode:SKNode = SKNode()
        groundNode.position = CGPointMake(0, 0)
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        groundNode.physicsBody?.dynamic = false
        groundNode.physicsBody?.categoryBitMask = objectGroup
        self.addChild(groundNode)
        
        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
    }
    
    func makeBackground() {
        var bgTexture:SKTexture = SKTexture(imageNamed: "bg.png")
        
        var moveBgAction:SKAction = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        var replaceBg:SKAction = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        var moveBgForever:SKAction = SKAction.repeatActionForever(SKAction.sequence([moveBgAction, replaceBg]))
        
        for var i:CGFloat = 0; i < 3; i++ {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width / 2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            
            bg.runAction(moveBgForever)
            
            movingObjects.addChild(bg)
        }
    }
    
    func makePipes() {
        if gameOver == 0 {
            let gapHeight:CGFloat = bird.size.height * 4
            
            var movementAmount:UInt32 = arc4random() % UInt32(self.frame.size.height / 2)
            var pipeOffset:CGFloat = CGFloat(movementAmount) - self.frame.size.height / 4
            
            var movePipes:SKAction = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
            var removePipes:SKAction = SKAction.removeFromParent()
            var moveAndRemovePipes:SKAction = SKAction.sequence([movePipes, removePipes])
            
            var topPipeTexture:SKTexture = SKTexture(imageNamed: "pipe1.png")
            var topPipe:SKSpriteNode = SKSpriteNode(texture: topPipeTexture)
            topPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + topPipe.size.height / 2 + gapHeight / 2 + pipeOffset)
            topPipe.runAction(moveAndRemovePipes)
            
            topPipe.physicsBody = SKPhysicsBody(rectangleOfSize: topPipe.size)
            topPipe.physicsBody?.dynamic = false
            topPipe.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(topPipe)
        
            var bottomPipeTexture:SKTexture = SKTexture(imageNamed: "pipe2.png")
            var bottomPipe:SKSpriteNode = SKSpriteNode(texture: bottomPipeTexture)
            bottomPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - bottomPipe.size.height / 2 - gapHeight / 2 + pipeOffset)
            bottomPipe.runAction(moveAndRemovePipes)
            
            bottomPipe.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPipe.size)
            bottomPipe.physicsBody?.dynamic = false
            bottomPipe.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(bottomPipe)
            
            var gap:SKNode = SKNode()
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame)  + pipeOffset)
            gap.runAction(moveAndRemovePipes)
            
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(topPipe.size.width, gapHeight))
            gap.physicsBody?.dynamic = false
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjects.addChild(gap)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score++
            scoreLabel.text = "\(score)"
        } else {
            if gameOver == 0 {
                gameOver = 1
                movingObjects.speed = 0
                
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelHolder.addChild(gameOverLabel)
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if gameOver == 0 {
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            
            movingObjects.removeAllChildren()
            labelHolder.removeAllChildren()
            
            makeBackground()
            
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            
            gameOver = 0
            movingObjects.speed = 1
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
