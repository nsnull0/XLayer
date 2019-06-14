//
//  DetailedInfoLabel.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/06/15.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

class DetailedInfoLabel: UILabel {
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
  override var intrinsicContentSize: CGSize {
    var intricSuperView = super.intrinsicContentSize
    intricSuperView.width += 20
    return intricSuperView
  }
  
  override func drawText(in rect: CGRect) {
    let edgeInsetCustom = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    super.drawText(in: rect.inset(by: edgeInsetCustom))
  }
}

