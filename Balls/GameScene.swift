import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    var backgroundMusicPlayer: AVAudioPlayer!
    let player = GameSprite(imageNamed: "player")
    let background = GameSprite(imageNamed: "starfield")
    let light = SKLightNode()
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Projectile: UInt32 = 0b10      // 2
    }
    
    // Main setup routine
    override func didMoveToView(view: SKView) {
        
        player.setScale(1.0)
        player.zPosition = 1.0
        backgroundColor = SKColor.clearColor()
        background.lightingBitMask = 1
        background.shadowedBitMask = 1

        light.categoryBitMask = 1
        light.falloff = 1.0
        light.ambientColor = SKColor.whiteColor().colorWithAlphaComponent(0.3)
        light.lightColor = SKColor.whiteColor().colorWithAlphaComponent(0.7)
        light.shadowColor = SKColor.blackColor().colorWithAlphaComponent(0.4)
        
        
        background.addChild(light)
        
        
        background.alpha = 0.0
        background.setScale(1.0)
        background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(background)
        let actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 240.0)
        let actionFadeIn = SKAction.fadeInWithDuration(3.0)
        background.runAction(SKAction.scaleBy(-0.1, duration: 240.0))
        background.runAction(SKAction.repeatActionForever(actionRotate))
        background.runAction(actionFadeIn)
        
        // 3
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        // 4
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(0.25)
                ])
            ))
        
        playBackgroundMusic("background-music-aac.caf")
        
    }
    
    override func willMoveFromView(view: SKView) {
        backgroundMusicPlayer.stop()
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        //let touch = touches.first as! UITouch
        
        // Make lots of stars in a spread
        
        //for y in -3...3 {
        
        for item in touches {
            let y = 0
            let touch = item as! UITouch
            createProjectile(touch.locationInNode(self), angleOffset:CGPoint(x: 0.0, y: 20.0 * Double(y)))
        }
        
        
        //}
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
    }
    
    func createProjectile(touchLocation: CGPoint, angleOffset: CGPoint)
    {
        
        // 2 - Set up initial location of projectile
        let projectile = Projectile(imageNamed: "projectile")
        projectile.name = "projectile"
        projectile.lifePoints = 1
        projectile.position = player.position
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position + angleOffset
        
        // 4 - Bail out if you are shooting down or backwards
        //if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        
        let actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        projectile.runAction(SKAction.repeatActionForever(actionRotate))
        
        
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(projectile:GameSprite, monster:GameSprite) {
        
        projectile.hit(monster)
        monster.hit(projectile)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                if ((firstBody.node) != nil && (secondBody.node) != nil) {
                projectileDidCollideWithMonster(secondBody.node as! GameSprite, monster: firstBody.node as! GameSprite)
                }
        }
        
    }

    func addMonster() {
        
        // Create sprite
        let monster = Monster(imageNamed: "asteroid")
        monster.name = "asteroid"
        monster.lifePoints = 3
        monster.lightingBitMask = 1
        monster.shadowedBitMask = 1
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5

        
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2,max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(10.0), max: CGFloat(16.0))
        
        // Determine size
        let actualScale = (random(min: CGFloat(1.0), max: CGFloat(6.0)))
        monster.setScale(actualScale / 6.0)
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        let actionRotate = SKAction.rotateByAngle(random(min: CGFloat(-1.0), max: CGFloat(1.0))*CGFloat(M_PI), duration:1)
        monster.runAction(SKAction.repeatActionForever(actionRotate))
        
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }

    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        backgroundMusicPlayer =
            AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }

    // Random functions
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}












