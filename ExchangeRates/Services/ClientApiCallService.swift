//
//  ClientApiCallService.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ClientApiCallService {
  static let shared = ClientApiCallService()
  private let caller:RequestCaller = RequestCaller(config: URLSessionConfiguration.default)
  private var lock:Bool = false
  private(set) var apiParam:NSDictionary!
  private(set) var config:NSDictionary!
  
  init() {
    refresh()
  }
  
  func refresh() {
    if let path = Bundle.main.path(forResource: "Api-Params", ofType: "plist") {
      if let root = NSDictionary(contentsOfFile: path){
        apiParam = root
      }
    }
    if let path = Bundle.main.path(forResource: "App-Config", ofType: "plist") {
      if let root = NSDictionary(contentsOfFile: path){
        config = root
      }
    }
  }
  
  func isReadyToUse() -> Bool{
    return (apiParam != nil && config != nil)
  }
  
  func getListApi(completion: @escaping (ResultFetch<DashboardResponseModel, Int>) -> Void){
    guard isReadyToUse() else { return }
    if let _baseUrl:String = config.value(forKey: "base_url") as? String,
      let _accessKey:String = apiParam.value(forKey: "secret_key") as? String{
      let requestModel = RequestModel(baseUrl: _baseUrl,
                                      httpMethod: .get,
                                      path: "list",
                                      query: ["Access_key": _accessKey])
      caller.fetch(requestModel.asURLRequest(), completion: {
        (result: ResultFetch<DashboardResponseModel, Int>) in
        DispatchQueue.main.async {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          let context = appDelegate.persistentContainer.viewContext
          switch result {
          case .successful(let obj):
            if let _arrCodeList = obj.currencyCodeList {
              for item in _arrCodeList {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entity().name!)
                fetchRequest.predicate = NSPredicate(format: "currency_id = %@", item.key)
                
                do {
                  let getCurrency = try context.fetch(fetchRequest)
                  if let _currencyObject = getCurrency.first as? NSManagedObject {
                    _currencyObject.setValue(item.key, forKey: "currency_id")
                    _currencyObject.setValue(item.value, forKey: "currency_description")
                  }else{
                    let entityRate = NSEntityDescription.entity(forEntityName: Currency.entity().name!, in: context)
                    let rate = NSManagedObject(entity: entityRate!, insertInto: context)
                    rate.setValue(item.key, forKey: "currency_id")
                    rate.setValue(item.value, forKey: "currency_description")
                  }
                  
                }catch{
                  print("can't update")
                }
                
              }
              do {
                try context.save()
              }catch{
                print("error save \(error.localizedDescription)")
              }
            }
          case .failure, .none:
            break
          }
          completion(result)
        }
      })
    }
  }
  
  func getRateApi(selectedCurrencyCode: String = "USD",
                  completion: @escaping (ResultFetch<DashboardResponseModel, Int>) -> Void){
    guard isReadyToUse() else { return }
    if let _baseUrl:String = config.value(forKey: "base_url") as? String,
      let _accessKey:String = apiParam.value(forKey: "secret_key") as? String{
      let requestModel = RequestModel(baseUrl: _baseUrl,
                                      httpMethod: .get,
                                      path: "live",
                                      query: ["Access_key": _accessKey,
                                              "source":selectedCurrencyCode])
      caller.fetch(requestModel.asURLRequest(), completion: {
        (result: ResultFetch<DashboardResponseModel, Int>) in
        DispatchQueue.main.async {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          let context = appDelegate.persistentContainer.viewContext
          switch result {
          case .successful(let obj):
            for item in obj.getQuotesForCoreData {
              let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entity().name!)
              fetchRequest.predicate = NSPredicate(format: "currency_id = %@", item.key)
              do {
                let getCurrency = try context.fetch(fetchRequest)
                if let _currencyObject = getCurrency.first as? NSManagedObject {
                  _currencyObject.setValue(item.value, forKey: "currency_rate")
                  _currencyObject.setValue(obj.getCurrencyTimeStampForUI, forKey: "currency_timestamp")
                }else{
                  let entityRate = NSEntityDescription.entity(forEntityName: Currency.entity().name!, in: context)
                  let rate = NSManagedObject(entity: entityRate!, insertInto: context)
                  rate.setValue(item.key, forKey: "currency_id")
                  rate.setValue(item.value, forKey: "currency_rate")
                  rate.setValue(obj.getCurrencyTimeStampForUI, forKey: "currency_timestamp")
                }
                
              }catch{
                print("can't update")
              }
              
            }
            
            do {
              try context.save()
            }catch {
              print("can't save upated")
            }
          case .failure, .none:
            break
          }
          completion(result)
        }
      })
    }
  }
  
  func getSpesificListRateApi(selectedSourceCurrencyCode: String = "USD",
                              listSpesificRateToSee: [String] = [],
                  completion: @escaping (ResultFetch<DashboardResponseModel, Int>) -> Void){
    guard isReadyToUse() else { return }
    if let _baseUrl:String = config.value(forKey: "base_url") as? String,
      let _accessKey:String = apiParam.value(forKey: "secret_key") as? String{
      let requestModel = RequestModel(baseUrl: _baseUrl,
                                      httpMethod: .get,
                                      path: "live",
                                      query: ["Access_key": _accessKey,
                                              "source":selectedSourceCurrencyCode,
                                              "currencies": listSpesificRateToSee.reduce("", {
                                                (result, current) -> String in
                                                var _result = result
                                                _result = "\(_result)\(current)"
                                                return _result
                                              })])
      caller.fetch(requestModel.asURLRequest(), completion: {
        (result: ResultFetch<DashboardResponseModel, Int>) in
        completion(result)
      })
    }
  }
}


