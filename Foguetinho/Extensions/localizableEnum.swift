//
//  localizableEnum.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 01/05/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation

enum Text: String  {
    case rotateTutorialWhiteMode
    case rotateTutorialPinkMode
    case tapTutorialPinkMode
    case currentScore
    case bestScore
    case releaseWhiteMode
    
    func localized() -> String {
        return self.rawValue.localized()
    }
}
