//
//  SwitchView.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/06/09.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

class SwitchView: UIView {

  override func draw(_ rect: CGRect) {
    drawLineSwitch(tag)
  }
  
  func drawLineSwitch(_ value: Int) {
    switch value {
    case 1:
      let path = UIBezierPath()
      path.move(to: CGPoint(x: 0, y: self.frame.size.height / 2))
      path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height / 2 + 13))
      UIColor.black.setStroke()
      path.lineWidth = 1.0
      path.stroke()
    default:
      let path = UIBezierPath()
      path.move(to: CGPoint(x: 0, y: self.frame.size.height / 2))
      path.addLine(to: CGPoint(x: self.frame.size.width, y: 5))
      UIColor.black.setStroke()
      path.lineWidth = 1.0
      path.stroke()
    }
  }
}
