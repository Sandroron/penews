//
//  ArticleListViewController.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

class ArticleListViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate, ArticleListFilterViewControllerDelegate,
    ScreenPresenter, PaginatedScreenPresenter {
    
    // MARK: - Constants
    
    private let dataBaseManager = DataBaseManagerImplementation()
    
    
    // MARK: - Outlets

    @IBOutlet weak var emptyResultView: UIView!
    @IBOutlet weak var errorConnectionView: UIView!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var stubView: UIView!
    @IBOutlet weak var stubViewActivityIndicator: UIActivityIndicatorView!

    
    // MARK: - Properties

    weak var paginationView: PaginationView!
    
    var filterBarButton: UIBarButtonItem!
    var sortBarButton: UIBarButtonItem!
    var likeBarButton: UIBarButtonItem!
    

    // MARK: - Computed properties

    // Небольшие костыли, чтобы не приводить постоянно типы Presenter-а
    var resultTableView:            UITableView         { get { return resultView       as! UITableView }}


    // MARK: - Private properties
    
    private var fethingMore = false // флаг разрешения подгрузки списка при прокрутке
    
    private var dataAdapter: ArticleListDataAdapter!
    
    private var q: String? {
        
        didSet {
            
            dataAdapter.configure(q: q, filter: filter)
            dataAdapter.loadFirstPage()
        }
    }
    
    private var filter: ArticleListFilter? {
        
        didSet {
            
            sortBarButton.isEnabled = !(filter?.sources?.isEmpty ?? true)
        }
        
    }
    
    private var sort: String = "publishedAt"
    private var isSortEnabled = false {
        
        didSet {
            
            if isSortEnabled {
                
                dataAdapter.configure(q: q, filter: filter, sortBy: sort)
                dataAdapter.loadFirstPage()
                
                navigationItem.title = "Sort by published at"
            } else {
                
                dataAdapter.configure(q: q, filter: filter)
                dataAdapter.loadFirstPage()
                
                navigationItem.title = "Top headlines"
            }
        }
    }


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
        dataAdapter = ArticleListDataAdapter(presenter: self, paginatedPresenter: self)
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        dataAdapter.configure()
        dataAdapter.loadFirstPage()
        
        resultTableView.register(cellType: ArticleTableViewCell.self)

        resultTableView.dataSource = self
        resultTableView.delegate = self
        resultTableView.estimatedRowHeight = 185.0 // TODO: Constants
        
        resultTableView.refreshControl = UIRefreshControl()
        resultTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)

        searchBar.delegate = self
        
        // Настройка пагинации
        paginationView = PaginationView.loadFromNib()
        paginationView.dataProvider = dataAdapter

        resultTableView.tableFooterView = paginationView
        
        filterBarButton = UIBarButtonItem(image: UIImage(named: "filter_24pt"), style: .plain, target: self, action: #selector(onFilterBarButtonTap))
        sortBarButton = UIBarButtonItem(image: UIImage(named: "sort_24pt"), style: .plain, target: self, action: #selector(onSortBarButtonTap))
        likeBarButton = UIBarButtonItem(image: UIImage(named: "heart_outline_24pt"), style: .plain, target: self, action: #selector(onLikeBarButtonTap))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [filterBarButton, sortBarButton]
        navigationItem.leftBarButtonItems = [likeBarButton]
        
        navigationItem.title = "Top headlines" // "Sort by published at"
        
        sortBarButton.isEnabled = !(filter?.sources?.isEmpty ?? true)
        
        stubViewActivityIndicator.startAnimating()
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
    }

    //override func viewDidDisappear(_ animated: Bool) {
    //    super.viewDidDisappear(animated)
    //}

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //    // Dispose of any resources that can be recreated.
    //}


    // MARK: - UITableView DataSource & Delegate

    func numberOfSections(in tableView: UITableView) -> Int {

        if tableView == resultTableView {
            
            return 1 // dataAdapter.pages?.count ?? 0
        } else {
            
            fatalError("Unknown UITableView.")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == resultTableView {
            
//            return dataAdapter.pages?[section].objects.count ?? 0
            return dataAdapter.objects?.count ?? 0
        } else {
            
            fatalError("Unknown UITableView.")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185.0 // TableView.Cell.Height.article
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == resultTableView {

            let cell = tableView.dequeueReusableCell(with: ArticleTableViewCell.self, for: indexPath)

            cell.setup(withArticle: dataAdapter.objects?[indexPath.row],
                       isLiked: dataBaseManager.isLiked(article: dataAdapter.objects?[indexPath.row]))
            
            cell.likeButton.indexPath = indexPath
            cell.likeButton.addTarget(self, action: #selector(onLikeButtonTap(_:)), for: .touchUpInside)
            
            return cell
        } else {

            fatalError("Unknown UITableView.")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= (dataAdapter.objects?.count ?? 0) - 2,
           !fethingMore {

            fethingMore = true

            paginationView.showLoadingView()

            dataAdapter.configure(q: q, filter: filter)
            dataAdapter.loadMore()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView == resultTableView,
           let urlString = dataAdapter.objects?[indexPath.row].url {

            guard let cell = tableView.cellForRow(at: indexPath) as? ArticleTableViewCell else {
                fatalError("The cell is not an instance of ArticleTableViewCell.")
            }

            cell.isSelected = false

            let articleViewController = ArticleViewController.loadFromNib().configure(urlString: urlString)
            navigationController?.pushViewController(articleViewController, animated: true)
        }
    }
    
    
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        q = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        q = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }


    // MARK: - PaginatedScreenPresenter

    func willShowEmptyResultView(dataAdapter: DataAdapter) {
        
        // Вид пустого состояния зависит того, искал ли пользователь что-либо.
        // Если строка поиска пуста, то покажем стандартную ошибку,
        // иначе – пустой результат поискового запроса.
//        if !(filters?.isEmpty ?? true) || sort != Endpoint.PickOptions.KeyValue.SortPairs.articles.first!.value {
//
//            emptyResultAdView.actionButton.removeTarget(nil, action: nil, for: .allEvents)
//
//            emptyResultAdView.setup(actionButtonText: "aShowAll".localized())
//            emptyResultAdView.actionButton.addTarget(self, action: #selector(onShowAllButtonTap(_:)), for: .touchUpInside)
//
//            emptyResultAdView.emptyDescriptionLabel.text = "mEmptySearch".localized()
//        } else {
//
//            emptyResultAdView.actionButton.removeTarget(nil, action: nil, for: .allEvents)
//
//            emptyResultAdView.setup(actionButtonText: "aToSendFeedback".localized())
//            emptyResultAdView.actionButton.addTarget(self, action: #selector(onFeedbackButtonTap(_:)), for: .touchUpInside)
//
//            emptyResultAdView.emptyDescriptionLabel.text = "mEmptyResultsContactSupportTeam".localized()
//        }
    }

    func willShowResultView(dataAdapter: DataAdapter) {
        
        fethingMore = false
        
        resultTableView.reloadData()
        resultTableView.refreshControl?.endRefreshing()
    }
    
    func willShowLoadMoreResultView(dataAdapter: DataAdapter) {
        
        fethingMore = false
        
        resultTableView.reloadData()
    }
    
    
    // MARK: - ArticleFilterPopupViewControllerDelegate
    
    func updateFilter(articleListFilter: ArticleListFilter) {
        
        filter = articleListFilter
        
        dataAdapter.configure(q: q, filter: articleListFilter)
        dataAdapter.loadFirstPage()
    }
    
    
    // MARK: - Methods
    
//    func performSearchAction() {
//
//        resultTableView.setContentOffset(.zero, animated: false)
//
//        if !(filters?.isEmpty ?? true) || sort != Endpoint.PickOptions.KeyValue.SortPairs.articles.first!.value {
//
//            dataAdapter.configure(q: nil, sort: sort, filters: filters)
//            dataAdapter.loadFirstPage()
//
//            showStubView(dataAdapter: dataAdapter)
//        } else {
//
//            dataAdapter.configure(articlesAlias: listAlias)
//            dataAdapter.loadFirstPage()
//
//            showStubView(dataAdapter: dataAdapter)
//        }
//    }


    // MARK: - Action methods
    
    @objc func handleRefreshControl() {
        
        dataAdapter.configure()
        dataAdapter.loadFirstPage()
    }
    
    @objc func onFilterBarButtonTap() {
        
        present(ArticleListFilterViewController.loadFromNib().configure(articleListFilter: filter, delegate: self), animated: true)
    }
    
    @objc func onSortBarButtonTap() {
        
        isSortEnabled = !isSortEnabled
    }
    
    @objc func onLikeBarButtonTap(_ sender: Any) {
        
        let articleLikeListViewController = ArticleLikeListViewController.loadFromNib()
        navigationController?.pushViewController(articleLikeListViewController, animated: true)
    }
    
    @objc func onLikeButtonTap(_ sender: LikeButton) {
        
        if let indexPath = sender.indexPath {
            
            sender.isLiked = !sender.isLiked
            dataBaseManager.save(article: dataAdapter.objects?[indexPath.row])
        }
    }
    
    @IBAction func onTryAgainButtonTap(_ sender: Any) {
        
        filter = nil
        
        searchBar.text = nil
        
        q = nil
    }
}
