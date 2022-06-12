//
//  GestureAnimationView.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 09/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation
import UIKit

enum GestureAnimationState {
    case end
    case rotate
    case tap
}

class GestureAnimationView: UIView {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var guideImage: UIImageView!
    
    var atualRotationGesture: CGFloat = CGFloat(0)
    var timerTutotial: Timer?
    
    func setup() {
        TitleLabel.text = Text.rotateTutorialWhiteMode.localized()
    }
    
    @objc func animateGestureRotate() {
        if (atualRotationGesture < CGFloat(Double.pi/10)) {
            self.guideImage.transform = self.guideImage.transform.rotated(by: CGFloat(Double.pi/10))
            atualRotationGesture += CGFloat(Double.pi/10)
        } else {
            self.guideImage.transform = self.guideImage.transform.rotated(by: CGFloat(-Double.pi/10))
            atualRotationGesture -= CGFloat(Double.pi/10)
        }
    }
    
    var random = 0
    @objc func animateGestureTap() {
        random += 1
        random = random == 3 ? 0 : random
        switch random {
        case 0:
            guideImage.image = UIImage(named: ImageName.twoTapImg1.rawValue)
        case 1:
            guideImage.image = UIImage(named: ImageName.twoTapImg2.rawValue)
        default:
            guideImage.image = UIImage(named: ImageName.twoTapImg3.rawValue)
        }
    }
    
    func endTutorial() {
        self.isHidden = true
    }
    
    func startTutorial() {
        self.isHidden = false
        timerTutotial?.invalidate()
        guideImage.image = UIImage(named: ImageName.rotateImage.rawValue)
        timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureRotate), userInfo: nil, repeats: true)
    }
    
    func tapTutorial() {
        timerTutotial?.invalidate()
        guideImage.image = UIImage(named: ImageName.twoTapImg1.rawValue)
        timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureTap), userInfo: nil, repeats: true)
    }
}

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view with type " + String(describing: type))
    }
}
