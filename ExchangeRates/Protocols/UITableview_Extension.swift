//
//  UITableview_Extension.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
  
  func register<T: NibLoadableViewProtocol & ReusableViewProtocol>(_ : T.Type) {
    register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeue<T: ReusableViewProtocol>(_ : T.Type) -> T? {
    return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T
  }
  
}

extension UITableViewCell : NibLoadableViewProtocol {}
extension UITableViewCell : ReusableViewProtocol {}
