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
  var resultQuery: Double?
  var dashboardQuery: DashboardDetailedQueryInfo?
  var dashboardQueryInfo: DashboardDetailedInfo?
  
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
    case resultQuery = "result"
    case dashboardQuery = "query"
    case dashboardQueryInfo = "info"
  }
}

struct DashboardDetailedQueryInfo: Codable {
  var currencyFrom:String
  var currencyTo:String
  var amount:Double
  
  enum CodingKeys: String, CodingKey {
    case currencyFrom = "from"
    case currencyTo = "to"
    case amount
  }
}

struct DashboardDetailedInfo: Codable {
  var timeDate:Double
  var quote:Double
  
  enum CodingKeys: String, CodingKey {
    case timeDate = "timestamp"
    case quote
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
  var getCurrencyConversionTimeStampForUI:String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY, MMM dd"
    let date = Date.init(timeIntervalSince1970: dashboardQueryInfo?.timeDate ?? 0)
    return "\(dateFormatter.string(from: date))"
  }
}
