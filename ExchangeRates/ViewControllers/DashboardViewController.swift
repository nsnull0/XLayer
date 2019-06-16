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
  @IBOutlet private weak var detailedInformationContainerHeight:NSLayoutConstraint!
  @IBOutlet private weak var detailedInformationContainerBottom:NSLayoutConstraint!
  @IBOutlet private weak var inputDetailRateContainerBottom:NSLayoutConstraint!
  @IBOutlet private weak var statusBarHeight:NSLayoutConstraint!
  @IBOutlet private weak var currencyConversionInputAmountTopSpace:NSLayoutConstraint!
  @IBOutlet private weak var detailedInformationContainer:UIView!
  @IBOutlet private weak var simpleButtonSelection:UIButton!
  @IBOutlet private weak var detailedButtonSelection:UIButton!
  @IBOutlet private weak var switchViewTop:SwitchView!
  @IBOutlet private weak var switchViewBot:SwitchView!
  @IBOutlet private weak var settingButton:UIButton!
  @IBOutlet private weak var inputDetailedRate:UITextField!
  @IBOutlet private weak var inputDetailedRateContainer:UIView!
  @IBOutlet private weak var currentInterfaceTypeDescription: UILabel!
  @IBOutlet private weak var currencyConversionTitleLabel:UILabel!
  @IBOutlet private weak var currencyConversionSourceLabel:UILabel!
  @IBOutlet private weak var currencyConversionQuoteLabel:UILabel!
  @IBOutlet private weak var currencyConversionAmountContainer:UIView!
  @IBOutlet private weak var currencyConversionAmountFieldLabel:UILabel!
  @IBOutlet private weak var currencyConversionResultLabel:UILabel!
  @IBOutlet private weak var currencyConversionInputAmountContainer:UIView!
  @IBOutlet private weak var currencyConversionInputAmountTextField:UITextField!
  @IBOutlet private weak var currencyConversionAmountFieldScrollView:UIScrollView!
  
  private var viewModel:DashboardViewModel!
  private var interfaceType:InterfaceType!{
    return viewModel.interfaceType
  }
  private var hasTopnotch:Bool {
    return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
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
    detailedInformationContainer.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
    }
    inputDetailedRateContainer.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
    }
    inputDetailedRate.configure{
      $0.keyboardType = UIKeyboardType.alphabet
      $0.autocorrectionType = UITextAutocorrectionType.no
      $0.autocapitalizationType = .allCharacters
      $0.backgroundColor = .clear
      $0.delegate = self
      $0.placeholder = "QUICK_SEARCH".localized
    }
    currencyConversionInputAmountTextField.configure{
      $0.keyboardType = UIKeyboardType.numberPad
      $0.autocorrectionType = UITextAutocorrectionType.no
      $0.autocapitalizationType = .allCharacters
      $0.backgroundColor = .clear
      $0.placeholder = "INPUT_AMOUNT".localized
      let barButtonDone = UIBarButtonItem(title: "DONE".localized, style: .done, target: self, action: #selector(tapDoneAmount))
      $0.addCancelAndDoneToolbar(barButtonDone: barButtonDone)
    }
    currencyConversionQuoteLabel.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionTitleLabel.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionAmountContainer.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionResultLabel.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionSourceLabel.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionInputAmountContainer.configure{
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 1
      $0.backgroundColor = UIColor.white
    }
    currencyConversionAmountFieldLabel.configure{
      $0.text = "1"
      $0.textAlignment = .center
    }
    currentInterfaceTypeDescription.text = viewModel.interfaceType.getDescription
    currencyConversionInputAmountTopSpace.constant = viewModel.interfaceType.getTopConversionInputAmount
    inputDetailRateContainerBottom.constant = viewModel.interfaceType.getBottomDetailedInputContainer
    detailedInformationContainerBottom.constant = viewModel.interfaceType.getBottomDetailedContainer
    detailedInformationContainerHeight.constant = viewModel.interfaceType.getHeightDetailedContainer
    statusBarHeight.constant = hasTopnotch ? 44 : 20
    switchViewTop.isHidden = false
    switchViewBot.isHidden = true
  }
  
  @IBAction func tapToPickSourceCurrencyCode(_ v:UITapGestureRecognizer) {
    listCurrencyCodeDropDownView.isHidden = !listCurrencyCodeDropDownView.isHidden
  }
  
  @objc private func timerRefresh(){
    _ = ClientApiCallService.shared.refresh()
  }
  
  @objc private func tapDoneAmount() {
    view.endEditing(true)
    guard currencyConversionInputAmountTextField.isValidText else {
      return
    }
    let inputRateCount = inputDetailedRate.text?.count ?? 0
    let inputRate = inputRateCount > 0 ? "\(inputDetailedRate.text!)" : viewModel.cachedInputAmountAndTarget.target
    viewModel.cachedInputAmountAndTarget = (amount: "\(currencyConversionInputAmountTextField.text ?? "")",
      target: inputRate)
    viewModel.refresh(clientApi: ClientApiCallService.shared)
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
    currentInterfaceTypeDescription.text = viewModel.interfaceType.getDescription
    UIView.animate(withDuration: 0.3, animations: {
      [weak self] in
      guard let _self = self else { return }
      _self.listCurrencyRateTopSpace.constant = _self.interfaceType.getTop
      _self.listCurrencyRateHeight.constant = _self.interfaceType.getHeight
      _self.detailedInformationContainerBottom.constant = _self.viewModel.interfaceType.getBottomDetailedContainer
      _self.detailedInformationContainerHeight.constant = _self.viewModel.interfaceType.getHeightDetailedContainer
      _self.inputDetailRateContainerBottom.constant = _self.viewModel.interfaceType.getBottomDetailedInputContainer
      _self.currencyConversionInputAmountTopSpace.constant = _self.viewModel.interfaceType.getTopConversionInputAmount
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
    case .conversionContent(let result,
                              let dateValue,
                              let target,
                              let quote,
                              let amount):
      DispatchQueue.main.async {
        [weak self] in
        self?.currencyConversionTitleLabel.text = "\(dateValue)"
        self?.currencyConversionSourceLabel.text = "\(target)"
        self?.currencyConversionQuoteLabel.text = "\("RATE_TITLE".localized) \(quote)"
        self?.currencyConversionResultLabel.text = "\(result)"
        self?.currencyConversionAmountFieldLabel.text = "\(amount)"
        let calculateWidth = NSString(string: "\(amount)").boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)], context: nil).width
        self?.currencyConversionAmountFieldScrollView.contentSize = CGSize(width: calculateWidth, height: 30)
      }
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

extension DashboardViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    guard textField.isValidText else {
      return false
    }
    let inputAmountCount = currencyConversionInputAmountTextField.text?.count ?? 0
    let inputAmount = inputAmountCount > 0 ? "\(currencyConversionInputAmountTextField.text!)" : viewModel.cachedInputAmountAndTarget.amount
    viewModel.cachedInputAmountAndTarget = (amount: inputAmount,
      target: "\(textField.text!)")
    viewModel.refresh(clientApi: ClientApiCallService.shared)
    return false
  }
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    switch textField {
    case inputDetailedRate:
      return ((textField.text?.count ?? 0) - range.length + string.count) <= 3
    case currencyConversionInputAmountTextField:
      return ((textField.text?.count ?? 0) - range.length + string.count) <= 10
    default:
      return true
    }
  }
}
