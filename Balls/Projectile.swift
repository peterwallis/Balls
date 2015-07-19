//
//  Projectile.swift
//  Balls
//
//  Created by Peter Wallis on 12/07/2015.
//  Copyright (c) 2015 PeterWallis. All rights reserved.
//

import UIKit
import SpriteKit

class Projectile: GameSprite {
    
    override func death() {
        
        super.death()
        
        self.removeFromParent()
    }
    
}
