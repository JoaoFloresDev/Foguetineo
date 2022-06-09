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

enum Default: String {
    
    case numberOfGames
    case bestScore
    
    func getValue() -> Int {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    func setValue(value: Int) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
}

//struct UserDefaultService {
//    var userDefaults = UserDefaults.standard
//
//    func getNumberOfGames() -> Int {
//        return userDefaults.integer(forKey: Key.numberOfGames.rawValue)
//    }
//
//    func setNumberOfGames(number: Int) {
//        UserDefaults.standard.set(number, forKey: Key.numberOfGames.rawValue)
//    }
//}
