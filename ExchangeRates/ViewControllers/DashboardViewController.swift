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
  @IBOutlet private weak var listCurrencyRateTopSpace:NSLayoutConstraint!
  @IBOutlet private weak var listCurrencyRateHeight:NSLayoutConstraint!
  @IBOutlet private weak var simpleButtonSelection:UIButton!
  @IBOutlet private weak var detailedButtonSelection:UIButton!
  @IBOutlet private weak var switchViewTop:SwitchView!
  @IBOutlet private weak var switchViewBot:SwitchView!
  @IBOutlet private weak var settingButton:UIButton!
  
  private var viewModel:DashboardViewModel!
  private var interfaceType:InterfaceType!{
    return viewModel.interfaceType
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle{
    return UIStatusBarStyle.lightContent
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel = DashboardViewModel(clientApi: ClientApiCallService.shared)
    viewModel.delegate = self
    viewModel.changeInterfaceType(.simple)
    
    if let root = ClientApiCallService.shared.config{
      if let refreshRate = root.value(forKey: "refresh_rate") as? String {
        Timer.scheduledTimer(
          timeInterval: Double(refreshRate)!,
          target: self,
          selector: #selector(timerRefresh), userInfo: nil, repeats: true)
      }
    }
    
    listCurrencyRateTopSpace.constant = interfaceType.getTop
    
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
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
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
    simpleButtonSelection.configure{
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.black.cgColor
      $0.setTitle("SIMPLE_SELECTION_BUTTON_TITLE".localized, for: .normal)
    }
    detailedButtonSelection.configure{
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.black.cgColor
      $0.setTitle("DETAILED_SELECTION_BUTTON_TITLE".localized, for: .normal)
    }
    settingButton.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.setTitle("SETTINGS".localized, for: .normal)
    }
    switchViewTop.isHidden = false
    switchViewBot.isHidden = true
  }
  
  @IBAction func tapToPickSourceCurrencyCode(_ v:UITapGestureRecognizer) {
    listCurrencyCodeDropDownView.isHidden = !listCurrencyCodeDropDownView.isHidden
  }
  
  @objc private func timerRefresh(){
    _ = ClientApiCallService.shared.refresh()
  }
  
  @IBAction func tapSimpleType(_ btn:UIButton){
    if btn.tag == 1 {
      switchViewTop.isHidden = true
      switchViewBot.isHidden = false
      viewModel.changeInterfaceType(.detailed)
    }else{
      switchViewTop.isHidden = false
      switchViewBot.isHidden = true
      viewModel.changeInterfaceType(.simple)
    }
    UIView.animate(withDuration: 0.3, animations: {
      [weak self] in
      guard let _self = self else { return }
      _self.listCurrencyRateTopSpace.constant = _self.interfaceType.getTop
      _self.listCurrencyRateHeight.constant = _self.interfaceType.getHeight
      _self.listCurrencyRateView.reloadData()
      _self.view.layoutIfNeeded()
    })
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
    _cell?.bind((name: viewModel.currencyRateItems[indexPath.section].items[indexPath.row].code, rate:"\(viewModel.currencyRateItems[indexPath.section].items[indexPath.row].rate ?? 0)", type: viewModel.currencyRateItems[indexPath.section].items[indexPath.row].type))
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
          _self.loadingLabel.text =  String(format: "ERROR_WITH_STATUS", "\(statusCode)")
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

extension DashboardViewController: UIScrollViewDelegate {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    switch scrollView {
    case listCurrencyRateView:
      let targetedOffsetX = Int(targetContentOffset.pointee.x) % 108
      if targetedOffsetX != 0 {
        scrollView.scrollRectToVisible(CGRect(x: Int(targetContentOffset.pointee.x) - targetedOffsetX, y: 0,
                                              width: 60, height: 60), animated: true)
      }
    default:
      break
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    switch scrollView {
    case listCurrencyRateView:
      let targetedOffsetX = Int(scrollView.contentOffset.x) % 108
      if targetedOffsetX != 0 {
        scrollView.scrollRectToVisible(CGRect(x: Int(scrollView.contentOffset.x) - targetedOffsetX, y: 0,
                                              width: 60, height: 60), animated: true)
      }
    default:
      break
    }
  }
}
