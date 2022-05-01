//
//  String+extension.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 01/05/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import Foundation
extension String {
    /// Uses NSLocalizedString to return a localized string,
    /// from the Localizable.strings file in the main bundle.
    /// - Note: Supporting English (Base) and Portuguese localization
    func localized() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
}
