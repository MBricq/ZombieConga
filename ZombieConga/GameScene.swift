//
//  GameScene.swift
//  ZombieConga
//
//  Created by Marin on 12/02/2018.
//  Copyright © 2018 Marin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK : Variables and constants
    // variables used to know the amount of time between two frames
    var lastTimeUpdate : TimeInterval = 0 //save the time of the last update
    var dt : TimeInterval = 0 // save the difference between the last update and the current one
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var zombieIsInvincible = false
    var lives = 5
    var gameOver = false
    var lastTouchedPosition = CGPoint.zero
    // this is the speed of the zombie per second and its speed of rotation
    let zombieMovePtsPerSec : CGFloat = 480
    let zombieRotateRdsPerSec : CGFloat = .pi*2
    let catMovePtsPerSec : CGFloat = 480
    // the velocity gives a vector so the zombie can go from a point A to a point B at its speed, at every frame it's multiplied to the time since the last frame to get exact distance the zombie should be moving
    var velocity = CGPoint.zero
    var zombieAnimation : SKAction
    
    override init(size: CGSize) {
        // create an animation for the zombie to run when moving
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        textures.append(textures[0])
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        // set the background image of the game
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1  // the default one is 0, we wanna be sure the background is behind everything else
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        addChild(zombie)
        
        // we use a weak reference of self to avoid a memory leak and every 4 seconds (time for a lady to cross) we make a new lady spawn
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run({[weak self] in
            self?.spawnEnemy()
        }), SKAction.wait(forDuration: 4)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run({[weak self] in
            self?.spawnCat()
        }), SKAction.wait(forDuration: 2)])))
    }
    
    // MARK : functions called at each frame
    // the update is the first one called, it's a perfect place to make the sprites move
    override func update(_ currentTime: TimeInterval) {
        if lastTimeUpdate > 0 {
            dt = currentTime - lastTimeUpdate
        } else {
            dt = 0
        }
        lastTimeUpdate = currentTime
        
        // if the zombie already arrived at the last touched position, it stops
        if ((lastTouchedPosition-zombie.position).length() <= (zombieMovePtsPerSec * CGFloat(dt))) {
            velocity = CGPoint.zero
            lastTouchedPosition = zombie.position
            stopZombieAnimation()
        } else {
            move(sprite: zombie, velocity: velocity)
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRdsPerSec)
        }
        
        // make the cats follow the player
        moveTrain()
        
        // check if the player lost
        checkIfGameIsOver()
    }
    
    // this function is called after the actions have been performed
    override func didEvaluateActions() {
        checkCollision()
    }
    // --------------------------------------------------------------
    
    
    
    // MARK : functions to move the zombie ----
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        // velocity is in pts/sec and dt in sec, so we have the distance in pts the zombie should be moving
        let amountToMove = velocity*CGFloat(dt)
        sprite.position += amountToMove
    }
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        // get the shortest angle between the the current angle (sprite.zRotation) and the target angle
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        // calculate the angle by which the sprite should rotate at this frame :
        /*  it can be either the speed of rotation of the zombie * he time spent since the last frame
         *  or the angle shortest, if this one is smaller than the first option
         */
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    func moveToward(sprite: SKSpriteNode, location: CGPoint) {
        startZombieAnimation()
        // calculating the vector of movement to go for the sprites from its position to location knowing its speed
        let offset = location - sprite.position
        let direction = offset.normalized()
        velocity = direction*zombieMovePtsPerSec
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
        zombie.texture = SKTexture(imageNamed: "zombie1")
    }
    // -----------------------------------------
    
    // MARK : detect a touch on the scene in order to make the zombie move there --
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchedPosition = touchLocation
        moveToward(sprite: zombie, location: lastTouchedPosition)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        sceneTouched(touchLocation: touch.location(in: self))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        sceneTouched(touchLocation: touch.location(in: self))
    }
    // ----------------------------------------------------------------------
    
    // MARK : actions runned by the enemy --
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: 450, max: size.height - enemy.size.height)) // put the enemy out of the screen on the left, in the middle of its height
        addChild(enemy)
        
        // create an action that moves a sprite to a CGPoint in 2 seconds and make the enemy run it
        let moveAcrossTheScreen = SKAction.moveTo(x: -enemy.size.width/2, duration: 4)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAcrossTheScreen, actionRemove]))
    }
    // --------------------------------------
    
    // MARK : actions and functions to deal with cats behavior --
    func spawnCat() {
        let pi : CGFloat = .pi
        // spawn a cat at a random position of the screen and then makes it invisible
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: cat.size.width, max: size.width - cat.size.width), y: CGFloat.random(min: 2*cat.size.height, max: size.height - (1.5*cat.size.height)))
        cat.setScale(0)
        cat.zRotation = -pi / 16
        addChild(cat)
        
        // make the cat appears, wait for 10 sec and disappears
        let appear = SKAction.scale(to: 1, duration: 0.5)
        
        // make the cat wiggle and scale up and down at the same time
        let leftWiggle = SKAction.rotate(byAngle: pi/8, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.1, duration: 0.5)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown])
        let group = SKAction.group([fullWiggle, fullScale])
        let wait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        let actions = SKAction.sequence([appear, wait, disappear, remove])
        cat.run(actions)
    }
    // ----------------------------------------------------------
    
    // MARK : properties to store the actions (it takes less memory to load the actions only once and call them later by the nodes)
    let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    // MARK : Collisions control --
    func zombieHit(cat: SKSpriteNode) {
        run(catCollisionSound)
        
        // the cat now become a part of the train
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        let turnGreen = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1, duration: 0.2)
        cat.run(turnGreen)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        run(enemyCollisionSound)
        zombieIsInvincible = true
        loseCats(numberOfCatsToLose: 2)
        lives -= 1
        
        // "Blink" action
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let afterBlinkingAction = SKAction.run {
            self.zombieIsInvincible = false
            self.zombie.isHidden = false
        }
        zombie.run(SKAction.sequence([blinkAction, afterBlinkingAction]))
    }
    
    func checkCollision() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { (node, _) in  // run through all the cats of the scene
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {     // if a cat collide with the zombie it is added to an array
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat) // and then we run a function on the cats hit
        }
        
        // does the same for the ladies but it checks only for a smaller frame to not check if the zombie collide with the umbrella
        if !zombieIsInvincible {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodes(withName: "enemy") { (node, _) in
                let enemy = node as! SKSpriteNode
                if enemy.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHit(enemy: enemy)
            }
        }
    }
    // ----------------------------
    
    func moveTrain() {
        var targetPosition = zombie.position
        
        // make each cats go to the location of the previous one
        enumerateChildNodes(withName: "train") { node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePtsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.move(by: CGVector(dx: amountToMove.x, dy: amountToMove.y), duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
    }
    
    /* this function is called to remove cats from the line, it takes in parameter:
        - numberOfCatsToLose: the number of cats to remove
     
        this number has to be positive
        it then goes through all the cats, pick one, make it goes do a random spot and disappear
    */
    func loseCats(numberOfCatsToLose: Int) {
        if numberOfCatsToLose > 0 {
            var loseCount = 0
            enumerateChildNodes(withName: "train", using: { (node, stop) in
                var randomSpot = node.position
                randomSpot.x += CGFloat.random(min: -100, max: 100)
                randomSpot.y += CGFloat.random(min: -100, max: 100)
                
                node.name = ""
                node.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.move(to: randomSpot, duration: 1),
                        SKAction.scale(to: 0, duration: 1)]),
                    SKAction.removeFromParent()
                ]))
                loseCount += 1
                if loseCount >= numberOfCatsToLose {
                    stop[0] = true
                }
            })
        }
    }
    
    func checkIfGameIsOver() {
        if lives <= 0 && !gameOver {
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        } else {
            var numberOfCats = 0
            enumerateChildNodes(withName: "train", using: { (_, _) in
                numberOfCats += 1
            })
            if numberOfCats >= 5 && !gameOver {
                gameOver = true
                let gameOverScene = GameOverScene(size: size, won: true)
                gameOverScene.scaleMode = scaleMode
                
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                
                view?.presentScene(gameOverScene, transition: reveal)
            }
        }
    }
}
