//
//  DashboardViewModel.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CurrencyItemCode {
  enum ItemType {
    case normal
    case nothing
  }
  var code: String
  var description: String
  var rate: Double?
  var type: ItemType = .normal
}

struct CurrencyItemRate {
  var items:[CurrencyItemCode]
}

protocol DashboardViewModelDelegate:class {
  func fetchStatus(_ v: DashboardViewModel.FetchStatus)
}

enum InterfaceType {
  case simple
  case detailed
  var getHeight:CGFloat {
    switch self {
    case .simple:
      return 212
    case .detailed:
      return 76
    }
  }
  var getTop:CGFloat {
    switch self {
    case .simple:
      return UIScreen.main.bounds.size.height - 444
    case .detailed:
      return 60
    }
  }
}

class DashboardViewModel {
  
  enum FetchStatus {
    case onProgressListFetch
    case onProgressRateFetch
    case completed
    case readyToShowCodeList(_ source:String, description:String)
    case readyToShowRateList
    case error(statusCode: Int)
    case errorConfig
  }
  
  private(set) var currencyCodeItems:[CurrencyItemCode] = []{
    didSet{
      delegate?.fetchStatus(.readyToShowCodeList(source, description: description))
    }
  }
  private(set) var currencyRateItems:[CurrencyItemRate] = []{
    didSet{
      delegate?.fetchStatus(.readyToShowRateList)
    }
  }
  weak var delegate:DashboardViewModelDelegate?
  private var loadingCombos:Int = 0 {
    didSet{
      guard loadingCombos == 0 else { return }
      DispatchQueue.main.async {
        [weak self] in
        guard let _self = self else { return }
        _self.delegate?.fetchStatus(.completed)
      }
    }
  }
  private var source:String = ""
  private var description:String = ""
  private(set) var interfaceType:InterfaceType = .simple
  
  init(clientApi: ClientApiCallService) {
    loadingCombos = 2
    delegate?.fetchStatus(.onProgressListFetch)
    delegate?.fetchStatus(.onProgressRateFetch)
    source = clientApi.apiParam.value(forKey: "source") as? String ?? ""
    contextDidSave(Notification(name: Notification.Name.NSManagedObjectContextDidSave))
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(contextDidSave(_:)),
                                           name: Notification.Name.NSManagedObjectContextDidSave,
                                           object: nil)
    
    clientApi.getListApi(completion: {
      [weak self] result in
      guard let _self = self else { return }
      _self.loadingCombos -= 1
      switch result {
      case .failure(let statusCode):
        _self.delegate?.fetchStatus(.error(statusCode: statusCode))
      case .successful, .none:
        break
      }
    })
    
    if let _sourceRate = clientApi.apiParam.value(forKey: "source") as? String {
      clientApi.getRateApi(selectedCurrencyCode: _sourceRate,
                           completion: {
                            [weak self] result in
                            guard let _self = self else { return }
                            _self.loadingCombos -= 1
                            switch result {
                            case .failure(let statusCode):
                              _self.delegate?.fetchStatus(.error(statusCode: statusCode))
                            case .successful, .none:
                              break
                            }
      })
    }else{
      delegate?.fetchStatus(.errorConfig)
    }
  }
  
  func changeInterfaceType(_ value: InterfaceType){
    interfaceType = value
    switch interfaceType {
    case .simple:
      currencyRateItems = currencyRateItems.reduce([], { (result, section) -> [CurrencyItemRate] in
        var _result = result
        for item in section.items {
          if let _last = _result.last {
            if _last.items.count == 0 || _last.items.count == 3  {
              let itemRate = CurrencyItemRate(items: [item])
              _result.append(itemRate)
            }else if _last.items.count < 3 {
              var items = _last.items
              items.append(item)
              let itemRate = CurrencyItemRate(items: items)
              _result[_result.count - 1] = itemRate
            }
          }else {
            let itemRate = CurrencyItemRate(items: [item])
            _result.append(itemRate)
          }
        }
        return _result
      })
    case .detailed:
      currencyRateItems = currencyRateItems.reduce([], { (result, section) -> [CurrencyItemRate] in
        var _result = result
        for item in section.items {
          let itemRate = CurrencyItemRate(items: [item])
          _result.append(itemRate)
        }
        return _result
      })
    }
  }
  
  func refresh(clientApi: ClientApiCallService, selectedSource: String){
    if let _apiParam = clientApi.apiParam {
      let data:NSMutableDictionary = NSMutableDictionary(dictionary: _apiParam)
      data.setValue(selectedSource, forKey: "source")
      do {
        try data.write(to: clientApi.documentAPIParamsDirectory())
      }catch {
        print("error write \(error)")
      }
      _ = clientApi.refresh()
    }
    if let _sourceRate = clientApi.apiParam.value(forKey: "source") as? String {
      loadingCombos = 1
      source = _sourceRate
      delegate?.fetchStatus(.onProgressRateFetch)
      clientApi.getRateApi(selectedCurrencyCode: _sourceRate,
                           completion: {
                            [weak self] result in
                            guard let _self = self else { return }
                            _self.loadingCombos -= 1
                            switch result {
                            case .failure(let statusCode):
                              _self.delegate?.fetchStatus(.error(statusCode: statusCode))
                            case .successful(_), .none:
                              break
                            }
      })
    }else{
      delegate?.fetchStatus(.errorConfig)
    }
  }
  
  @objc func contextDidSave(_ notification:Notification) {
    DispatchQueue.main.async {
      [weak self] in
      guard let _self = self else { return }
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entity().name!)
      let fetchSourceRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entity().name!)
      fetchSourceRequest.predicate = NSPredicate(format: "currency_id = %@", _self.source)
      do {
        let getUpdatedCore = try context.fetch(fetchRequest) as! [Currency]
        if let getSourceCore = try context.fetch(fetchSourceRequest) as? [Currency] {
          if getSourceCore.count > 0 {
            _self.description = "\(getSourceCore[0].currency_description ?? "") \n\(String(describing: getSourceCore[0].currency_timestamp ?? ""))"
          }
        }
        _self.currencyCodeItems = []
        _self.currencyRateItems = []
        var tempCodeItems: [CurrencyItemCode] = []
        for item in getUpdatedCore {
          let item = CurrencyItemCode(code: item.currency_id!,
                                      description: item.currency_description ?? "",
                                      rate: item.currency_rate, type: .normal)
          tempCodeItems.append(item)
        }
        let itemNothingType = CurrencyItemCode(code: "", description: "", rate: nil, type: .nothing)
        tempCodeItems.append(contentsOf: [itemNothingType, itemNothingType, itemNothingType])
        _self.currencyCodeItems = tempCodeItems
        let currencyRateItems = _self.currencyCodeItems.reduce([]) { (result, current) -> [CurrencyItemRate] in
          var _result = result
          switch _self.interfaceType {
          case .simple:
            if let _last = _result.last {
              if _last.items.count == 0 || _last.items.count == 3  {
                let itemRate = CurrencyItemRate(items: [current])
                _result.append(itemRate)
              }else if _last.items.count < 3 {
                var items = _last.items
                items.append(current)
                let itemRate = CurrencyItemRate(items: items)
                _result[_result.count - 1] = itemRate
              }
            }else {
              let itemRate = CurrencyItemRate(items: [current])
              _result.append(itemRate)
            }
          case .detailed:
            let itemRate = CurrencyItemRate(items: [current])
            _result.append(itemRate)
          }
          return _result
        }
        _self.currencyRateItems = currencyRateItems
        print("code \(String(describing: _self.currencyCodeItems.count))")
        print("rate \(String(describing: _self.currencyRateItems.count))")
      }catch{
        
      }
    }
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
  }
}


