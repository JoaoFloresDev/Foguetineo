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
    case release
}

class GestureAnimationView: UIView {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var guideImage: UIImageView!
    
    var atualRotationGesture: CGFloat = CGFloat(0)
    var timerTutotial: Timer?
    var currentState: GestureAnimationState = .end
    
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
    
    var imageIndex = 0
    @objc func animateGestureTap() {
        imageIndex += 1
        imageIndex = imageIndex == 3 ? 0 : imageIndex
        switch imageIndex {
        case 0:
            guideImage.image = UIImage(named: ImageName.twoTapImg.rawValue+"1")
        case 1:
            guideImage.image = UIImage(named: ImageName.twoTapImg.rawValue+"2")
        default:
            guideImage.image = UIImage(named: ImageName.twoTapImg.rawValue+"3")
        }
    }
    
    @objc func releaseGestureTap() {
        imageIndex += 1
        imageIndex = imageIndex == 3 ? 0 : imageIndex
        switch imageIndex {
        case 0:
            guideImage.image = UIImage(named: ImageName.releaseImage.rawValue+"1")
        default:
            guideImage.image = UIImage(named: ImageName.releaseImage.rawValue+"2")
        }
    }
    
    func endTutorial() {
        self.isHidden = true
    }
    
    func rotateTutorial() {
        if currentState == .rotate {
            return
        }
        currentState = .rotate
        
        self.isHidden = false
        timerTutotial?.invalidate()
        guideImage.image = UIImage(named: ImageName.rotateImage.rawValue)
        timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureRotate), userInfo: nil, repeats: true)
        TitleLabel.text = Text.rotateTutorialWhiteMode.localized()
    }
    
    func tapTutorial() {
        if currentState == .tap {
            return
        }
        currentState = .tap
        
        self.isHidden = false
        timerTutotial?.invalidate()
        imageIndex = 1
        guideImage.image = UIImage(named: ImageName.twoTapImg.rawValue+"1")
        timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.releaseGestureTap), userInfo: nil, repeats: true)
        TitleLabel.text = Text.tapTutorialPinkMode.localized()
    }
    
    func releaseTutorial() {
        if currentState == .release {
            return
        }
        currentState = .release
        
        self.isHidden = false
        timerTutotial?.invalidate()
        imageIndex = 1
        guideImage.image = UIImage(named: ImageName.releaseImage.rawValue+"1")
        timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.releaseGestureTap), userInfo: nil, repeats: true)
        TitleLabel.text = Text.releaseWhiteMode.localized()
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
