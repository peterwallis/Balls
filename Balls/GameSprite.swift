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
    
    var invicible:Bool = false
    var lifePoints:Int = 1   // Default number of life points.
    var damage = 1           // Damage in life points this object incurs.
    

    
    func hit( bySprite:GameSprite ) {
        // decrement life points
        
        if (invicible == false) {
            lifePoints -= bySprite.damage
        }
            
        if (lifePoints <= 0) { death() }
    }
    
    // Runs when a given sprite has no life points left.
    
    func death () {

        //println ("death has occured to \(self.name!).")

    }
    
    class func add(scene:SKScene) {
        print ("GameSprite has been created.")

    }
    
}
