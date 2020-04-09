//
//  TutorialFunctions.swift
//  Rocket
//
//  Created by Joao Flores on 21/07/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit

class TutorialFunctions: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
