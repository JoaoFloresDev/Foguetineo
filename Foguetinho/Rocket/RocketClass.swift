//
//  RocketClass.swift
//  Rocket
//
//  Created by Joao Flores on 21/07/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit
import AVFoundation

class RocketClass {
    var atualRotationRocket: CGFloat = CGFloat(Double.pi/2)
    var sinus: CGFloat = 0
    var cosinus: CGFloat = 0
    var dist: CGFloat = UIScreen.main.bounds.width/400
    var rocketImg: UIImageView
    var backGroundImg: UIImageView
    var moving = false
    
    init(rocketImg: UIImageView, backGroundImg: UIImageView) {
        self.rocketImg = rocketImg
        self.backGroundImg = backGroundImg
        
        self.rocketImg.center.x = backGroundImg.center.x
        self.rocketImg.center.y = backGroundImg.center.y*2 - self.rocketImg.frame.height*3
        
        rocketImg.frame.size = CGSize(width: 50, height: 70)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAnimation(mode: String) {
        
        var images: [UIImage] = []
        if(mode == "Pink") {
            for i in 1...2 {
                images.append(UIImage(named: "rocketPink\(i)")!)
            }
        }
        
        else {
            for i in 1...2 {
                images.append(UIImage(named: "rocketWhite\(i)")!)
            }
        }
        
        rocketImg.animationImages = images
        rocketImg.animationDuration = 0.3
        rocketImg.startAnimating()
    }
    
    func atualizeVelocity(points: Int) {
        if(points < 15){
            self.dist += UIScreen.main.bounds.width / 40000//0.0025
        } else if (points < 80) {
            self.dist += UIScreen.main.bounds.width / 20000 //0.01
        } else if (points < 100) {
            self.dist += UIScreen.main.bounds.width / 30000
        } else{ self.dist += UIScreen.main.bounds.width / 70000 }
    }
    
    func atualizeDirection() {
        self.sinus = sin(self.atualRotationRocket)
        self.cosinus = cos(self.atualRotationRocket)
    }
    
    func rotate(rotation: CGFloat) {
        self.rocketImg.transform = self.rocketImg.transform.rotated(by: rotation)
        self.atualRotationRocket += rotation
        
        if(self.atualRotationRocket > CGFloat(Double.pi*2)) { self.atualRotationRocket -= CGFloat(Double.pi*2) }
        else if(self.atualRotationRocket < CGFloat(-Double.pi*2)) { self.atualRotationRocket += CGFloat(Double.pi*2) }
    }
    
    func fly() {
        UIView.animate(withDuration: 0.005, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            
            self.rocketImg.center.y -= self.sinus * self.dist
            self.rocketImg.center.x -= self.cosinus * self.dist
        }, completion: nil)
    }
    
    func flyInitPosition(duration: TimeInterval) {
        
        UIView.animate(withDuration: duration, delay: 0.5, options: UIView.AnimationOptions.curveLinear, animations: {
            
            self.rocketImg.center.x = self.backGroundImg.center.x
            self.rocketImg.center.y = self.backGroundImg.center.y*2 - self.rocketImg.frame.height*1.5
            let rotation = -self.atualRotationRocket + .pi/2
            self.rocketImg.transform = self.rocketImg.transform.rotated(by: rotation)
        }, completion: nil)
        
        self.atualRotationRocket = .pi/2
    }
    
    func stopAnimation() {
        self.rocketImg.stopAnimating()
    }
    
    func resetParameters() {
        self.rocketImg.stopAnimating()
        self.dist = UIScreen.main.bounds.width/400
        self.moving = false
        
    }
}
