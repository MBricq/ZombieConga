//
//  MenuScene.swift
//  ZombieConga
//
//  Created by Marin on 15/02/2018.
//  Copyright © 2018 Marin. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = self.scaleMode
        let transition = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
