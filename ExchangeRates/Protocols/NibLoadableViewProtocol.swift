//
//  NibLoadableViewProtocol.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

protocol NibLoadableViewProtocol {
  static var nib:UINib { get }
}

extension NibLoadableViewProtocol where Self: UIView {
  static var nib: UINib {
    let className = String(describing: self)
    return UINib(nibName: className, bundle: Bundle(for: self))
  }
  
  static func view() -> Self? {
    return nib.instantiate(withOwner: self, options: nil).first as? Self
  }
}
