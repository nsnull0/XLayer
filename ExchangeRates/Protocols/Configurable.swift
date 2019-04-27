//
//  Configurable.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

protocol Configurable {}

extension Configurable {
  @discardableResult func configure ( block : (inout Self) -> Void ) -> Self {
    var m = self
    block(&m)
    return m
  }
}
