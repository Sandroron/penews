//
//  ArticleListFilterViewController.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 26.03.2022.
//

import UIKit

class ArticleListFilterViewController: UIViewController,
    UIPickerViewDelegate, UIPickerViewDataSource,
    NoViewLoadingPresenter {

    // MARK: - Outlets
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var stubView: UIView!
    @IBOutlet weak var stubViewActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var sourceTextField: UITextField!
    
    
    // MARK: - Constants
    
    let categoryPickerData = [nil, "business", "entertainment", "general", "health", "science", "sports", "technology"]
    let countryPickerData = [nil, "ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    var sourcePickerData = [Source?]()
    
    let categoryPickerView = UIPickerView()
    let countryPickerView = UIPickerView()
    let sourcePickerView = UIPickerView()
    
    
    // MARK: - Properties
    
    var articleListFilter = ArticleListFilter()
    weak var delegate: ArticleListFilterViewControllerDelegate?
    
    private var dataAdapter: SourceListDataAdapter!
    
    
    // MARK: - Inits
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    private func setup() {
        
        // Создаем адаптер сразу при инициализации контроллера,
        // чтобы дальнейшие обращения к нему не вызывали исключения
        dataAdapter = SourceListDataAdapter(presenter: self)
    }
    
    
    // MARK: - Configuration
    
    func configure(articleListFilter: ArticleListFilter?, delegate: ArticleListFilterViewControllerDelegate?) -> ArticleListFilterViewController {
        
        self.articleListFilter = articleListFilter ?? ArticleListFilter()
        self.delegate = delegate
        
        return self
    }
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stubViewActivityIndicator.startAnimating()
        
        dataAdapter.configure(category: articleListFilter.category, country: articleListFilter.country)
        dataAdapter.load()
        
        categoryPickerView.delegate = self
        countryPickerView.delegate = self
        sourcePickerView.delegate = self
        
        categoryTextField.inputView = categoryPickerView
        countryTextField.inputView = countryPickerView
        sourceTextField.inputView = sourcePickerView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onDismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dataAdapter.startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dataAdapter.stopListening()
        
        delegate?.updateFilter(articleListFilter: articleListFilter)
    }

    //override func viewDidDisappear(_ animated: Bool) {
    //    super.viewDidDisappear(animated)
    //}
    
    
    // MARK: UIPickerView Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == categoryPickerView {
            
            return categoryPickerData.count
        } else if pickerView == countryPickerView {
            
            return countryPickerData.count
        } else if pickerView == sourcePickerView {
            
            return sourcePickerData.count
        } else {
            
            fatalError("Unknown pickerView")
        }
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == categoryPickerView {
            
            return categoryPickerData[row]
        } else if pickerView == countryPickerView {
            
            return countryPickerData[row]
        } else if pickerView == sourcePickerView {
            
            return sourcePickerData[row]?.name
        } else {
            
            fatalError("Unknown pickerView")
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView == categoryPickerView {

            categoryTextField.text = categoryPickerData[row]
            articleListFilter.category = categoryPickerData[row]
            
            updateSources()
        } else if pickerView == countryPickerView {

            countryTextField.text = countryPickerData[row]
            articleListFilter.country = countryPickerData[row]
            
            updateSources()
        } else if pickerView == sourcePickerView {

            sourceTextField.text = sourcePickerData[row]?.name
            articleListFilter.sources = sourcePickerData[row]?.id
        } else {

            fatalError("Unknown pickerView")
        }
    }
    
    
    // MARK: - ScreenPresenter
    
    func willShowEmptyResultView(dataAdapter: DataAdapter) {
        
        resultView.isHidden = false
        stubView.isHidden = true
    }
    
    func willShowResultView(dataAdapter: DataAdapter) {
        
        if let sources = self.dataAdapter.objects {
            
            resultView.isHidden = false
            stubView.isHidden = true
            
            sourcePickerData = [Source(name: "All", id: nil)] + sources
            
            sourcePickerView.reloadAllComponents()
            
            if let categoryIndex = categoryPickerData.firstIndex(of: articleListFilter.category) {
                
                categoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
                categoryTextField.text = categoryPickerData[categoryIndex]
            }
            
            if let countryIndex = countryPickerData.firstIndex(of: articleListFilter.country) {
                
                countryPickerView.selectRow(countryIndex, inComponent: 0, animated: false)
                countryTextField.text = countryPickerData[countryIndex]
            }
            
            if let sourceIndex = sourcePickerData.map({ $0?.id }).firstIndex(of: articleListFilter.sources) {
                
                sourcePickerView.selectRow(sourceIndex, inComponent: 0, animated: false)
                sourceTextField.text = sourcePickerData[sourceIndex]?.name
            }
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateSources() {
        
        dataAdapter.configure(category: articleListFilter.category, country: articleListFilter.country)
        dataAdapter.load()
        
        sourceTextField.text = nil
    }
    
    
    // MARK: - Action methods
    
    @objc func onDismissKeyboard(_ sender: Any) {
        
        view.endEditing(true)
    }
}

protocol ArticleListFilterViewControllerDelegate: AnyObject {
    
    func updateFilter(articleListFilter: ArticleListFilter)
}
