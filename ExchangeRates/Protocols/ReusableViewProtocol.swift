//
//  ReusableViewProtocol.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit
protocol ReusableViewProtocol {
  static var reuseIdentifier:String { get }
}

extension ReusableViewProtocol {
  static var reuseIdentifier:String {
    let className = String(describing: self)
    return "\(className)"
  }
}
