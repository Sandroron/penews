//
//  PaginationView.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

class PaginationView: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    // MARK: - Constants
    
    
    // MARK: - Properties
    
    var dataProvider: PaginationViewDataProvider?
    
    
    // MARK: - Methods

    func hideLoadingView() {
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    func showLoadingView() {
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
}

protocol PaginationViewDataProvider {
    
    // MARK: - Properties
    var countAllObjects:    Int     { get }
    var countObjectsOnPage: Int     { get }
    var countPagesInBlock:  Int     { get } 
    var currentPageNum:     Int     { get }
    var loadedPagesNums:    [Int]   { get }
    
    // MARK: - Methods
    func isAvailableMore() -> Bool
    func isAvailableNextPage() -> Bool
    func isAvailablePage(num pageNum: Int) -> Bool
    func isLoadedPage(num pageNum: Int) -> Bool
    func loadFirstPage()
    func loadMore()
}

