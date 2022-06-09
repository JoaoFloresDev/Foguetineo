//
//  Utils+UserDefault.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 08/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation

enum IntDefault: String {
    
    case numberOfGames
    case bestScore
    case BS
    
    func getValue() -> Int {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    func setValue(value: Int) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
}

enum BoolDefault: String {
    
    case bestScore
    
    func getValue() -> Bool {
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    func setValue(value: Bool) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
}
