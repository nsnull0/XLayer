//
//  CurrencyCodePickerCell.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

class CurrencyCodePickerCell: UITableViewCell {
  
  @IBOutlet private weak var currencyCodeNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func bind(_ data: String){
    currencyCodeNameLabel.text = data
  }
}

