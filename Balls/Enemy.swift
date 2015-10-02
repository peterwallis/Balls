//
//  Enemy.swift
//  Balls
//
//  Created by Peter Wallis on 12/07/2015.
//  Copyright (c) 2015 PeterWallis. All rights reserved.
//

import UIKit
import SpriteKit


class Enemy: GameSprite {
    
    override func death() {
        
        // NOTE: Users must manually remove item from parent.
        
        super.death()
        
        self.runAction(
            SKAction.sequence([
                SKAction.fadeOutWithDuration(0.4),
                SKAction.removeFromParent()
                ])
        )
        
        
    }
    
    override func hit(bySprite: GameSprite) {
        
        super.hit(bySprite)
        
        let explosion = SKEmitterNode(fileNamed: "Explosion.sks")
        explosion!.alpha = 0
        
        explosion!.setScale(2.0 / (CGFloat(self.lifePoints) + 1))
        
        self.addChild(explosion!)
        explosion!.runAction(
            SKAction.sequence([
                SKAction.playSoundFileNamed("grenade.mp3", waitForCompletion: false),
                SKAction.fadeInWithDuration(0.3),
                SKAction.fadeOutWithDuration(0.3),
                SKAction.removeFromParent()
                ])
        )
        
        
    }
    
    override class func add(scene:SKScene) {
        
        // Create sprite
        let monster = Enemy(imageNamed: "asteroid")
        monster.name = "asteroid"
        monster.lifePoints = 3
        monster.lightingBitMask = 1
        //monster.shadowCastBitMask = 1
        monster.zPosition = 0.5
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.Projectile | GameScene.PhysicsCategory.Player// 4
        monster.physicsBody?.collisionBitMask = GameScene.PhysicsCategory.None // 5
        
        
        // Determine where to spawn the monster along the Y axis
        let actualY = mmrandom(min: scene.size.height * 0.15, max: scene.size.height * 0.85 )
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: scene.size.width + scene.size.width/2, y: actualY)
        
        // Add the monster to the scene
        scene.addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(10.0), max: CGFloat(16.0))
        
        // Determine size
        let actualScale = (random(min: CGFloat(1.0), max: CGFloat(6.0)))
        monster.setScale(actualScale / 6.0)
        
        // Create the actions
        
        let ydelta = (random(min: CGFloat(-500.0), max: CGFloat(500.0)))
        let actionMove = SKAction.moveTo(CGPoint(x: -scene.size.width/2, y: actualY + ydelta), duration: NSTimeInterval(actualDuration))
        
        let actionRotate = SKAction.rotateByAngle(random(min: CGFloat(-1.0), max: CGFloat(1.0))*CGFloat(M_PI), duration:1)
        monster.runAction(SKAction.repeatActionForever(actionRotate))
        
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
}