//
//  ExchangeRatesTests.swift
//  ExchangeRatesTests
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class ExchangeRatesTests: XCTestCase {

  func testClientServiceInitiate(){
    let clientService = ClientApiCallService.shared
    XCTAssertTrue(clientService.isReadyToUse())
  }
  
  func testClientServiceRefresh() {
    let clientService = ClientApiCallService.shared
    XCTAssertTrue(clientService.refresh())
  }
  
  func testClientServiceToCallList() {
    let clientService = ClientApiCallService.shared
    let expectation = XCTestExpectation(description: "test call list api")
    
    clientService.getListApi(completion: {
      result in
      switch result{
      case .failure(let statusCode):
        XCTAssert(statusCode > -1)
        XCTAssert(statusCode != 200)
        XCTAssert(statusCode != 1)
      case .successful(let v):
        XCTAssertTrue(v.successFlag)
        XCTAssertNil(v.currencyQuotes)
        XCTAssertNotNil(v.currencyCodeList)
      default:
        break
      }
      expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 10.0)
    
  }
  
  func testClientServiceToCallRate(){
    let clientService = ClientApiCallService.shared
    let expectation = XCTestExpectation(description: "test call Rate api")
    let expectation2 = XCTestExpectation(description: "test call Rate selected source api")
    
    clientService.getRateApi(completion: {
      result in
      switch result{
      case .failure(let statusCode):
        XCTAssert(statusCode > -1)
        XCTAssert(statusCode != 200)
        XCTAssert(statusCode != 1)
      case .successful(let v):
        XCTAssertTrue(v.successFlag)
        XCTAssertNil(v.currencyCodeList)
        XCTAssertNotNil(v.currencyQuotes)
        XCTAssertNotNil(v.sourceCurrency)
        XCTAssertEqual(v.sourceCurrency!, "USD")
        print("\(String(describing: v.currencyQuotes))")
      default:
        break
      }
      expectation.fulfill()
    })
    
    clientService.getRateApi(selectedCurrencyCode: "JPY",
                             completion: {
                              result in
                              switch result{
                              case .failure(let statusCode):
                                XCTAssert(statusCode > -1)
                                XCTAssert(statusCode != 200)
                                XCTAssert(statusCode != 1)
                              case .successful(let v):
                                XCTAssertTrue(v.successFlag)
                                XCTAssertNil(v.currencyCodeList)
                                XCTAssertNotNil(v.currencyQuotes)
                                XCTAssertNotNil(v.sourceCurrency)
                                XCTAssertEqual(v.sourceCurrency!, "JPY")
                                print("\(String(describing: v.currencyQuotes))")
                              default:
                                break
                              }
                              expectation2.fulfill()
    })
    
    wait(for: [expectation, expectation2], timeout: 10.0)
  }
  
  func testClientServiceToCallRateSpesific() {
    let clientService = ClientApiCallService.shared
    let expectation = XCTestExpectation(description: "test call Rate api")
    let expectation2 = XCTestExpectation(description: "test call Rate selected Rate api")
    
    clientService.getSpesificListRateApi(completion: {
      result in
      switch result{
      case .failure(let statusCode):
        XCTAssert(statusCode > -1)
        XCTAssert(statusCode != 200)
        XCTAssert(statusCode != 1)
      case .successful(let v):
        XCTAssertTrue(v.successFlag)
        XCTAssertNil(v.currencyCodeList)
        XCTAssertNotNil(v.currencyQuotes)
        XCTAssertNotNil(v.sourceCurrency)
        XCTAssertEqual(v.sourceCurrency!, "USD")
        XCTAssert(v.currencyQuotes!.count > 1)
        print("\(String(describing: v.currencyQuotes))")
      default:
        break
      }
      expectation.fulfill()
    })
    
    clientService.getSpesificListRateApi(selectedSourceCurrencyCode: "JPY",
                                         listSpesificRateToSee: ["USD, EUR, IDR"],
                                         completion: {
                              result in
                              switch result{
                              case .failure(let statusCode):
                                XCTAssert(statusCode > -1)
                                XCTAssert(statusCode != 200)
                                XCTAssert(statusCode != 1)
                              case .successful(let v):
                                XCTAssertTrue(v.successFlag)
                                XCTAssertNil(v.currencyCodeList)
                                XCTAssertNotNil(v.currencyQuotes)
                                XCTAssertNotNil(v.sourceCurrency)
                                XCTAssertEqual(v.sourceCurrency!, "JPY")
                                XCTAssertEqual(v.currencyQuotes!.count, 3)
                                print("\(String(describing: v.currencyQuotes))")
                              default:
                                break
                              }
                              expectation2.fulfill()
    })
    
    wait(for: [expectation, expectation2], timeout: 10.0)
  }
  
  func testClientServiceToCallConversion() {
    let clientService = ClientApiCallService.shared
    let expectation = XCTestExpectation(description: "test call Rate api")
    
    clientService.getSpesificConversionCurrency(completion: {
      result in
      switch result {
      case .failure(let statusCode):
        XCTAssert(statusCode > -1)
        XCTAssert(statusCode != 200)
        XCTAssert(statusCode != 1)
      case .successful(let obj):
        XCTAssertTrue(obj.successFlag)
        XCTAssertNotNil(obj.resultQuery)
        XCTAssertNotNil(obj.dashboardQueryInfo)
        XCTAssertNotNil(obj.dashboardQuery)
        if let _query = obj.dashboardQuery {
          XCTAssertTrue(_query.currencyFrom == "USD")
          XCTAssertTrue(_query.currencyTo == "GBP")
        }
      case .none:
        break
      }
      expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 10)
  }

}
