//
//  SpriteEnhancements.swift
//  Balls
//
//  Created by Peter Wallis on 5/07/2015.
//  Copyright (c) 2015 PeterWallis. All rights reserved.
//

import UIKit
import SpriteKit

class GameSprite: SKSpriteNode {
    
    var lifePoints:Int = 1   // Default number of life points.
    var damage = 1           // Damage in life points this object incurs.
    
    func hit( bySprite:GameSprite ) {
        // decrement life points
        lifePoints -= bySprite.damage
        
        if (lifePoints <= 0) { death() }
    }
    
    // Runs when a given sprite has no life points left.
    
    func death () {

        println ("death has occured to \(self.name!).")

    }
    
    
}

class Projectile: GameSprite {

    override func death() {
        
        super.death()
        
        self.removeFromParent()
    }


    
}


class Monster: GameSprite {
    

    
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
        explosion.alpha = 0
        
        explosion.setScale(2.0 / (CGFloat(self.lifePoints) + 1))
        
        self.addChild(explosion)
        explosion.runAction(
            SKAction.sequence([
                SKAction.playSoundFileNamed("grenade.mp3", waitForCompletion: false),
                SKAction.fadeInWithDuration(0.3),
                SKAction.fadeOutWithDuration(0.3),
                SKAction.removeFromParent()
                ])
        )
        
        
    }
    
    
}