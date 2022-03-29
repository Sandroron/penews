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
    private let sort = "publishedAt"
    
    
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

    var resultTableView:            UITableView         { get { return resultView       as! UITableView }}


    // MARK: - Private properties
    
    private var fethingMore = false // flag for allowing fething for pagination
    
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
        resultTableView.estimatedRowHeight = TableView.Cell.Height.article
        
        resultTableView.refreshControl = UIRefreshControl()
        resultTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)

        searchBar.delegate = self
        
        // Настройка пагинации
        paginationView = PaginationView.loadFromNib()
        paginationView.dataProvider = dataAdapter

        resultTableView.tableFooterView = paginationView
        
        filterBarButton = UIBarButtonItem(image: .filter,       style: .plain, target: self, action: #selector(onFilterBarButtonTap))
        sortBarButton   = UIBarButtonItem(image: .sort,         style: .plain, target: self, action: #selector(onSortBarButtonTap))
        likeBarButton   = UIBarButtonItem(image: .heartOutline, style: .plain, target: self, action: #selector(onLikeBarButtonTap))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [filterBarButton, sortBarButton]
        navigationItem.leftBarButtonItems = [likeBarButton]
        
        navigationItem.title = "Top headlines"
        
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
            
            return 1 
        } else {
            
            fatalError("Unknown UITableView.")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == resultTableView {
            
            return dataAdapter.objects?.count ?? 0
        } else {
            
            fatalError("Unknown UITableView.")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableView.Cell.Height.article
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
