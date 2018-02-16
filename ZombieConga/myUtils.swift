//
//  myUtils.swift
//  ZombieConga
//
//  Created by Marin on 14/02/2018.
//  Copyright © 2018 Marin. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

// background music for the game
var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let resourceURL = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let url = resourceURL else {
        print("Could not find the file: \(filename)")
        return
    }
    
    do {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch {
        print("Could not create audio player!")
        return
    }
}

// functions used to make maths with CGPoints easier ---------
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}
func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}
func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}
func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}
func /= ( left: inout CGPoint, right: CGPoint) {
    left = left / right
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
func /= (point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}
// -----------------------------------------------------------

// function used to find the shortest angle between two others
func shortestAngleBetween(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    var angle = (angle2 - angle1).truncatingRemainder(dividingBy: .pi*2) // soustrait l'angle1 à l'angle2 puis garde uniquement le reste de la division euclidienne par 2π, angle appartient à ]-2π;2π[
    if angle >= .pi {
        angle = angle - .pi*2 //si angle > π alors un angle equivalent mais plus petit va dans le sens indirect, on le calcule ici
    }
    if angle <= -.pi {
        angle = angle + .pi*2 // on fait là l'inverse
    }
    return angle // ainsi angle appartient maintenat à [-π;π]
}

// extension of CGFloat to get the sign of a number easily
extension CGFloat {
    func sign() -> CGFloat {
        return self >= 0.0 ? 1.0 : -1.0 // retourne 1 si le CGFloat est positif ou nul, sinon -1
    }
}

// extensions of CGFloat to get random numbers
extension CGFloat {
    // return a number between 0 and 1
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    // return a random number between min and max
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
