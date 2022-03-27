//
//  ArticleLikeListViewController.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 28.03.2022.
//

import UIKit

class ArticleLikeListViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Constants
    
    private let dataBaseManager = DataBaseManagerImplementation()
    
    
    // MARK: - Outlets

    @IBOutlet weak var resultTableView: UITableView!


    // MARK: - Private properties
    
    private lazy var articles: [Article?] = {
        
        return dataBaseManager.obtainArticles()
    }()


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        resultTableView.register(cellType: ArticleTableViewCell.self)

        resultTableView.dataSource = self
        resultTableView.delegate = self
        resultTableView.estimatedRowHeight = 185.0 // TODO: Constants
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resultTableView.reloadData()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


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
            
            return articles.count
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

            cell.setup(withArticle: articles[indexPath.row],
                       isLiked: dataBaseManager.isLiked(article: articles[indexPath.row]))
            
            cell.likeButton.indexPath = indexPath
            cell.likeButton.addTarget(self, action: #selector(onLikeButtonTap(_:)), for: .touchUpInside)
            
            return cell
        } else {

            fatalError("Unknown UITableView.")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView == resultTableView,
           let urlString = articles[indexPath.row]?.url {

            guard let cell = tableView.cellForRow(at: indexPath) as? ArticleTableViewCell else {
                fatalError("The cell is not an instance of ArticleTableViewCell.")
            }

            cell.isSelected = false

            let articleViewController = ArticleViewController.loadFromNib().configure(urlString: urlString)
            navigationController?.pushViewController(articleViewController, animated: true)
        }
    }


    // MARK: - Action methods
    
    @objc func onLikeButtonTap(_ sender: LikeButton) {
        
        if let indexPath = sender.indexPath {
            
            sender.isLiked = !sender.isLiked
            dataBaseManager.save(article: articles[indexPath.row])
        }
    }
}
