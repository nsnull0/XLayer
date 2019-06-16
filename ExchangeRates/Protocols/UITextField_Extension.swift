//
//  UITextField_Extension.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/06/15.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

extension UITextField {
  func addCancelAndDoneToolbar(barButtonDone: UIBarButtonItem? = nil) {
    let doneBarButton = barButtonDone ?? UIBarButtonItem(title: "DONE".localized, style: .done, target: self, action: #selector(tapDone))
    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.items = [
      UIBarButtonItem(title: "CANCEL".localized, style: .plain, target: self, action: #selector(tapCancel)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
      doneBarButton
    ]
    toolbar.sizeToFit()
    inputAccessoryView = toolbar
  }
  
  @objc func tapDone() { self.resignFirstResponder() }
  @objc func tapCancel() { self.resignFirstResponder() }
  
  var isValidText:Bool {
    let textCount = text?.count ?? 0
    return textCount > 0
  }
}
