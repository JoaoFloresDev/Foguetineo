//
//  Utils+UserDefault.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 08/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation

enum ProtectionMode: String {
    case calculator
    case noProtection
    case bank
}

enum Key: String {
    case numberOfGames
    case firstUse
}

struct UserDefaultService {
    var userDefaults = UserDefaults.standard
    
    func getNumberOfGames() -> Int {
        return userDefaults.integer(forKey: Key.numberOfGames.rawValue)
    }

    func setNumberOfGames(number: Int) {
        UserDefaults.standard.set(number, forKey: Key.numberOfGames.rawValue)
    }
}
