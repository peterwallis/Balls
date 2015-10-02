//
//  Projectile.swift
//  Balls
//
//  Created by Peter Wallis on 12/07/2015.
//  Copyright (c) 2015 PeterWallis. All rights reserved.
//

import UIKit
import SpriteKit

class Player: GameSprite {
        
    override func hit(bySprite: GameSprite) {
        
        super.hit(bySprite)
        
        if lifePoints <= 0 {
        
            let explosion = SKEmitterNode(fileNamed: "PlayerDeath.sks")
            explosion!.alpha = 0
        
            explosion!.setScale(4.0 / (CGFloat(self.lifePoints) + 1))
        
            self.addChild(explosion!)
            explosion!.runAction(
            SKAction.sequence([
                SKAction.playSoundFileNamed("grenade.mp3", waitForCompletion: false),
                SKAction.fadeInWithDuration(0.3),
                SKAction.fadeOutWithDuration(0.3),
                SKAction.removeFromParent()
                ])
            )
        
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.removeFromParent()]))
        
        }
    }
    
}
