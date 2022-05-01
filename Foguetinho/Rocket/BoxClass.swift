//
//  RocketClass.swift
//  Rocket
//
//  Created by Joao Flores on 21/07/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit
import AVFoundation

class BoxClass {
    
    var boxImg: UIImageView
    var labelBox: UILabel
    var colorBox:Int = 0
    var backGroundImg: UIImageView
    
    init(boxImg: UIImageView, labelBox: UILabel, backGroundImg: UIImageView) {
        self.boxImg = boxImg
        self.labelBox = labelBox
        self.backGroundImg = backGroundImg
        
        let rect = CGRect(x: backGroundImg.center.x, y: 50, width: 100, height: 100)
        boxImg.frame = rect
        boxImg.center.x = backGroundImg.center.x
        self.labelBox.font = UIFont(name:"Futura", size: 30)
        labelBox.center = boxImg.center
        labelBox.text = "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func atualizePositionBox(sizeScreen: CGSize) {
        var randomInt = Double.random(in: Double(boxImg.frame.width)..<Double(sizeScreen.width - boxImg.frame.width))
        boxImg.center.x = CGFloat(randomInt)
        
        randomInt = Double.random(in: Double(boxImg.frame.width)..<Double(sizeScreen.height - boxImg.frame.height))
        boxImg.center.y = CGFloat(randomInt)
        
        labelBox.center = boxImg.center
    }
    
    func atualizeColorBox() {
        colorBox += 1
        
        if(colorBox == 130) {
            colorBox = 0
        }
        
        switch colorBox {
        case 0:
            boxImg.image = (UIImage(named: "disc1")!)
            
        case 10:
            boxImg.image = (UIImage(named: "disc2")!)
            
        case 20:
            boxImg.image = (UIImage(named: "disc3")!)
            
        case 30:
            boxImg.image = (UIImage(named: "disc4")!)
            
        case 40:
            boxImg.image = (UIImage(named: "disc5")!)
            
        case 50:
            boxImg.image = (UIImage(named: "disc6")!)
            
        case 60:
            boxImg.image = (UIImage(named: "disc7")!)
            
        case 70:
            boxImg.image = (UIImage(named: "disc8")!)
            
        case 80:
            boxImg.image = (UIImage(named: "disc9")!)
            
        case 90:
            boxImg.image = (UIImage(named: "disc10")!)
            
        case 100:
            boxImg.image = (UIImage(named: "disc11")!)
            
        case 110:
            boxImg.image = (UIImage(named: "disc12")!)
            
        case 120:
            boxImg.image = (UIImage(named: "disc13")!)
            
        default: break
        }
    }
    
    func atualizeLabelBox(points: Int) {
        if(points == 100) {
            self.labelBox.font = UIFont(name:"Futura", size: 22)
        } else if(points == 0) {
            self.labelBox.font = UIFont(name:"Futura", size: 30)
        }
    
        labelBox.text = String(Int(points))
    }
    
    func resetParameters() {
        colorBox = 0
        boxImg.center = backGroundImg.center
        boxImg.center.y = 100
        labelBox.center = boxImg.center
    }
    
    
}
