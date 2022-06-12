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
