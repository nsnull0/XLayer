//
//  DashboardResponseModel.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import Foundation

struct DashboardResponseModel:Codable {
  var successFlag: Bool
  var termsLink: String
  var privacyLink: String
  var lastDate:  Double?
  var currentDateHistory: String?
  var historicalFlag: Bool?
  var sourceCurrency: String?
  var currencyQuotes: [String : Double]?
  var currencyCodeList: [String : String]?
  
  enum CodingKeys: String, CodingKey {
    case successFlag = "success"
    case termsLink = "terms"
    case privacyLink = "privacy"
    case lastDate = "timestamp"
    case currentDateHistory = "date"
    case historicalFlag = "historical"
    case sourceCurrency = "source"
    case currencyQuotes = "quotes"
    case currencyCodeList = "currencies"
  }
}

extension DashboardResponseModel {
  var getQuotesForCoreData:[String : Double] {
    return currencyQuotes == nil ? [:] : currencyQuotes!.reduce([:], { (result, current) -> [String : Double] in
      var _result = result
      let indexStartOfText = current.key.index(current.key.startIndex, offsetBy: 3)
      let keyString:String = String(current.key[indexStartOfText...])
      _result[keyString] = current.value
      return _result
    })
  }
  var getCurrencyTimeStampForUI:String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    let date = Date.init(timeIntervalSince1970: lastDate ?? 0)
    return "\(dateFormatter.string(from: date))"
  }
}
