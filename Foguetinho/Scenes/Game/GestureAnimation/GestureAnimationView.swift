//
//  GestureAnimationView.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 09/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation
import UIKit

class GestureAnimationView: UIView {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var guideImage: UIImageView!
    
    func setup() {
        TitleLabel.text = Text.rotateTutorialWhiteMode.localized()
        
        let timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureRotate), userInfo: nil, repeats: true)
    }
    
    var atualRotationGesture: CGFloat = CGFloat(0)
    
    @objc func animateGestureRotate() {
        if(atualRotationGesture < CGFloat(Double.pi/10))
        {
            self.guideImage.transform = self.guideImage.transform.rotated(by: CGFloat(Double.pi/10))
            atualRotationGesture += CGFloat(Double.pi/10)
        }
        
        else
        {
            self.guideImage.transform = self.guideImage.transform.rotated(by: CGFloat(-Double.pi/10))
            atualRotationGesture -= CGFloat(Double.pi/10)
        }
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
