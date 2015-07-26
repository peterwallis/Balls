import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    var backgroundMusicPlayer: AVAudioPlayer!
    var player = Player(imageNamed: "player")
    let background = GameSprite(imageNamed: "starfield")
    let light = SKLightNode()
    let monsterSpawnWait = 0.5 // seconds
    var projectileSet: Set<NSTimer> = []
    var scoreLabel:SKLabelNode = SKLabelNode(text: "")
    var gameOverLabel:SKLabelNode = SKLabelNode(text: "Game Over")
    var score  = 0
    var gameOver = false
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Projectile: UInt32 = 0b10      // 2
        static let Player    : UInt32 = 0b100     // 3
    }
    
    // Main setup routine
    override func didMoveToView(view: SKView) {
        
        initGame()
        
    }
    
    func initGame () {
        
        gameOver = false
        
        player = Player(imageNamed: "player")
        player.setScale(1.0)
        player.zPosition = 1.0
        player.shadowCastBitMask = 1
        player.lifePoints = 1
        
        player.position = CGPoint(x: size.width * 0.25, y: size.height * 0.5)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size) // 1
        player.physicsBody?.dynamic = true // 2
        player.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Player // 3
        player.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.Monster // 4
        player.physicsBody?.collisionBitMask = GameScene.PhysicsCategory.None // 5
        self.addChild(player)
        
        
        backgroundColor = SKColor.clearColor()
        background.lightingBitMask = 1
        
        light.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        light.zPosition = 1
        light.categoryBitMask = 1
        light.falloff = 1.0
        light.ambientColor = SKColor.whiteColor().colorWithAlphaComponent(0.3)
        light.lightColor = SKColor.whiteColor().colorWithAlphaComponent(0.7)
        light.shadowColor = SKColor.blackColor().colorWithAlphaComponent(0.05)
        
        
        self.addChild(light)
        
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: size.width * 0.98, y: size.height * 0.95)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        scoreLabel.text = "\(score)"
        
        self.addChild(scoreLabel)
        
        
        background.alpha = 0.0
        background.setScale(1.0)
        background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(background)
        let actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 240.0)
        let actionFadeIn = SKAction.fadeInWithDuration(3.0)
        //background.runAction(SKAction.scaleBy(-0.1, duration: 240.0))
        background.runAction(SKAction.repeatActionForever(actionRotate))
        background.runAction(actionFadeIn)
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        let actBlock = SKAction.runBlock({
            Enemy.add(self)
        })
        
        let sequenceAction = SKAction.sequence([actBlock,SKAction.waitForDuration(monsterSpawnWait)])
        
        runAction(SKAction.repeatActionForever(sequenceAction), withKey:"spawnEnemys")
        
        playBackgroundMusic("background-music-aac.caf")
        
    }
    
    func resetGame () {
        self.removeAllActions()
        self.removeAllChildren()
        initGame()
    }
    
    func GameOver () {
        
        gameOverLabel.fontSize = 150.0
        gameOverLabel.alpha = 0.0
        gameOverLabel.setScale(0.5)
        gameOverLabel.zPosition = 1.0
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        self.addChild(gameOverLabel)
        gameOverLabel.runAction(
            SKAction.sequence([
                SKAction.fadeInWithDuration(1.0)
                ]))
        let scaleAction = SKAction.scaleTo(1.0, duration: 1.0)
        scaleAction.timingMode = SKActionTimingMode.EaseInEaseOut
        gameOverLabel.runAction(scaleAction)
        gameOver = true
        
        for snode in self.children {
            if (snode is Enemy) {
                
                let gamesprite = snode as! Enemy
                
                gamesprite.runAction(SKAction.fadeOutWithDuration(2.0))
                
            }
            
        }
        
        removeActionForKey("spawnEnemys")
        
    }
    
    
    
    override func willMoveFromView(view: SKView) {
        backgroundMusicPlayer.stop()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        if (!gameOver) {
        
            if (touches.count <= 3 && projectileSet.count <= 3) {
                
                for item in touches {
                    let touch = item as! UITouch
                    
                    let timer = NSTimer.every(0.05) {
                        self.createProjectile(touch.locationInNode(self), angleOffset:CGPoint(x: 0.0, y: 0.0))
                    }
                    
                    projectileSet.insert(timer)
                    
                }
            } else {
                removeProjectileSet()
            }
            
        }
        else {
            resetGame()
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        removeProjectileSet()
        
    }
    
    func removeProjectileSet () {
        for projectileTimer in projectileSet {
            NSTimer.after(0.16) { projectileTimer.invalidate() }
            projectileSet.remove(projectileTimer)
        }
    }
    
    func createProjectile(touchLocation: CGPoint) {
        createProjectile(touchLocation, angleOffset:CGPoint(x: 0.0, y: 0.0))
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
        let actionSound = SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false)
        let actionMove = SKAction.sequence([SKAction.moveTo(realDest, duration: 2.0), SKAction.removeFromParent()])
        let actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.25)
        let projectileAction = SKAction.group([actionSound, actionMove, actionRotate])
        
        projectile.runAction(projectileAction)
    }
    
    func projectileDidCollideWithMonster(projectile:GameSprite, monster:GameSprite) {
        
        projectile.hit(monster)
        monster.hit(projectile)
        
        score += 1
        
        scoreLabel.alpha = 1.0
        scoreLabel.text = "\(score)"
        
        
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
        
        if (secondBody.node is Player) {
            player.hit(firstBody.node as! Enemy)
            
            if (gameOverLabel.parent != self) {
                GameOver()
            
            }
        }
        else
        {
        // 2
            if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                    if ((firstBody.node) != nil && (secondBody.node) != nil) {
                        projectileDidCollideWithMonster(secondBody.node as! GameSprite, monster: firstBody.node as! GameSprite)
                    }
            }
        }
        
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


}

