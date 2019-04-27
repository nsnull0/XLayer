//
//  String_Extension.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//
import Foundation
extension String  {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
