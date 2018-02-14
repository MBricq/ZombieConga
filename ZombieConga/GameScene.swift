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
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastTouchedPosition = CGPoint.zero
    // variables used to know the amount of time between two frames
    var lastTimeUpdate : TimeInterval = 0 //save the time of the last update
    var dt : TimeInterval = 0 // save the difference between the last update and the current one
    // this is the speed of the zombie per second and its speed of rotation
    let zombieMovePtsPerSec : CGFloat = 480
    let zombieRotateRdsPerSec : CGFloat = .pi*2
    // the velocity gives a vector so the zombie can go from a point A to a point B at its speed, at every frame it's multiplied to the time since the last frame to get exact distance the zombie should be moving
    var velocity = CGPoint.zero
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        // set the background image of the game
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1  // the default one is 0, we wanna be sure the background is behind everything else
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie.setScale(2) // multiply its width and height by two
        addChild(zombie)
        
    }
    
    // this function is called at each frame, it's a perfect place to make the sprites move
    override func update(_ currentTime: TimeInterval) {
        
        // if the zombie already arrived at the last touched position, it stops
        if ((lastTouchedPosition-zombie.position).length() <= (zombieMovePtsPerSec * CGFloat(dt))) {
            velocity = CGPoint.zero
            lastTouchedPosition = zombie.position
        } else {
            move(sprite: zombie, velocity: velocity)
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRdsPerSec)
        }
        
        if lastTimeUpdate > 0 {
            dt = currentTime - lastTimeUpdate
        } else {
            dt = 0
        }
        lastTimeUpdate = currentTime
        
    }
    
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
        // calculating the vector of movement to go for the sprites from its position to location knowing its speed
        let offset = location - sprite.position
        let direction = offset.normalized()
        velocity = direction*zombieMovePtsPerSec
    }
    
    // detect a touch on the scene in order to make the zombie move their
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
}
