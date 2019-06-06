//
//  ViewController.swift
//  ExchangeRates
//
//  Created by Yoseph Wijaya on 2019/04/27.
//  Copyright © 2019 olala. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
  
  @IBOutlet private weak var topSourceCurrencyDescription:UILabel!
  @IBOutlet private weak var topSourceCurrencyDescriptionContainer:UIView!
  @IBOutlet private weak var topSourceCurrencyCode:UILabel!
  @IBOutlet private weak var topSourceCurrencyStaticLabel:UILabel!
  @IBOutlet private weak var topSourceCurrencyPickerContainer:UIView!
  @IBOutlet private weak var listCurrencyRateView:UICollectionView!
  @IBOutlet private weak var listCurrencyCodeDropDownView:UITableView!
  @IBOutlet private weak var loadingView:UIView!
  @IBOutlet private weak var loadingLabel:UILabel!
  @IBOutlet private weak var loadingIndicator:UIActivityIndicatorView!
  @IBOutlet private weak var loadingViewTopConstraint:NSLayoutConstraint!
  
  private var viewModel:DashboardViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel = DashboardViewModel(clientApi: ClientApiCallService.shared)
    viewModel.delegate = self
    
    if let root = ClientApiCallService.shared.config{
      if let refreshRate = root.value(forKey: "refresh_rate") as? String {
        Timer.scheduledTimer(
          timeInterval: Double(refreshRate)!,
          target: self,
          selector: #selector(timerRefresh), userInfo: nil, repeats: true)
      }
    }
    
    
    
    loadingLabel.configure {
      $0.text = "FETCH_LIST".localized
    }
    loadingIndicator.configure{
      $0.startAnimating()
    }
    listCurrencyRateView.configure {
      $0.delegate = self
      $0.dataSource = self
      $0.showsVerticalScrollIndicator = false
      $0.showsHorizontalScrollIndicator = false
      $0.register(CurrencyRateCellCollectionViewCell.self)
    }
    listCurrencyCodeDropDownView.configure {
      $0.delegate = self
      $0.dataSource = self
      $0.isHidden = true
      $0.register(CurrencyCodePickerCell.self)
      $0.clipsToBounds = true
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.black.cgColor
    }
    topSourceCurrencyStaticLabel.configure{
      $0.text = "\u{25BC}"
    }
    topSourceCurrencyPickerContainer.configure{
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.black.cgColor
    }
    topSourceCurrencyDescriptionContainer.configure{
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.black.cgColor
    }
  }
  
  @IBAction func tapToPickSourceCurrencyCode(_ v:UITapGestureRecognizer) {
    listCurrencyCodeDropDownView.isHidden = !listCurrencyCodeDropDownView.isHidden
  }
  
  @objc private func timerRefresh(){
    _ = ClientApiCallService.shared.refresh()
  }
}

extension DashboardViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.currencyRateItems[section].items.count
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return viewModel.currencyRateItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let _cell  = collectionView.dequeue(CurrencyRateCellCollectionViewCell.self, for: indexPath)
    _cell?.bind((name: viewModel.currencyRateItems[indexPath.section].items[indexPath.row].code, rate:"\(viewModel.currencyRateItems[indexPath.section].items[indexPath.row].rate ?? 0)"))
    return _cell!
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 60)
  }
}

extension DashboardViewController:UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.currencyCodeItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let _cell: CurrencyCodePickerCell = tableView.dequeue(CurrencyCodePickerCell.self)!
    _cell.bind(viewModel.currencyCodeItems[indexPath.row].code)
    return _cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    listCurrencyCodeDropDownView.isHidden = true
    viewModel.refresh(clientApi: ClientApiCallService.shared,
                      selectedSource: viewModel.currencyCodeItems[indexPath.row].code)
  }
  
}

extension DashboardViewController:DashboardViewModelDelegate {
  func fetchStatus(_ v: DashboardViewModel.FetchStatus) {
    switch v {
    case .completed:
      if loadingViewTopConstraint.constant >= 0 {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          guard let _self = self else { return }
          _self.loadingViewTopConstraint.constant = -60
          _self.loadingIndicator.stopAnimating()
          _self.loadingLabel.text = ""
          _self.loadingView.layoutIfNeeded()
        })
      }
    case .error(let statusCode):
      if loadingViewTopConstraint.constant >= 0 {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          guard let _self = self else { return }
          _self.loadingViewTopConstraint.constant = -60
          _self.loadingIndicator.stopAnimating()
          _self.loadingLabel.text = "status code error \(statusCode)"
          _self.view.layoutIfNeeded()
        })
      }
    case .errorConfig:
      if loadingViewTopConstraint.constant < 0 {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          guard let _self = self else { return }
          _self.loadingViewTopConstraint.constant = 0
          _self.loadingIndicator.startAnimating()
          _self.loadingLabel.text = "ERROR_CONFIG".localized
          _self.view.layoutIfNeeded()
        })
      }
    case .onProgressListFetch:
      if loadingViewTopConstraint.constant < 0 {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          guard let _self = self else { return }
          _self.loadingViewTopConstraint.constant = 0
          _self.loadingIndicator.startAnimating()
          _self.loadingLabel.text = "FETCH_LIST_IN_PROGRESS".localized
          _self.view.layoutIfNeeded()
        })
      }
    case .onProgressRateFetch:
      if loadingViewTopConstraint.constant < 0 {
        UIView.animate(withDuration: 0.3, animations: {
          [weak self] in
          guard let _self = self else { return }
          _self.loadingViewTopConstraint.constant = 0
          _self.loadingIndicator.startAnimating()
          _self.loadingLabel.text = "FETCH_RATE_IN_PROGRESS".localized
          _self.view.layoutIfNeeded()
        })
      }
    case .readyToShowCodeList(let source, let description):
      topSourceCurrencyCode.text = source
      topSourceCurrencyDescription.text = description
      listCurrencyCodeDropDownView.reloadData()
    case .readyToShowRateList:
      listCurrencyRateView.reloadData()
    }
  }
}
