//
//  ArticleViewController.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 26.03.2022.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var articleWebView: WKWebView!
    
    
    // MARK: - Properties
    
    var url: URL!
    
    
    // MARK: - Configuration
    
    func configure(urlString: String) -> ArticleViewController {
        
        url = URL(string: urlString)

        return self
    }
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = URLRequest(url: url)
        articleWebView.load(request)
    }
}
