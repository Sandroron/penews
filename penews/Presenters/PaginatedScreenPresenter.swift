//
//  PaginatedScreenPresenter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

@objc protocol PaginatedScreenPresenter: NoViewLoadingMorePresenter, PaginationViewProvider {
}

extension PaginatedScreenPresenter {
    
    // MARK: - Methods
    
    func setLoadingMoreState(_ loadingMoreState: LoadingMoreState, dataAdapter: DataAdapter) {
        //print("PaginatedScreenPresenter.setLoadingMoreState(loadingMoreState: \(loadingMoreState))")
        
        switch loadingMoreState {
            
        case .loadMoreEmpty:
            showLoadMoreEmptyResultView(dataAdapter: dataAdapter)
            
        case .loadMoreError:
            showLoadMoreErrorConnectionView(dataAdapter: dataAdapter)
            
        case .loadMoreResult:
            showLoadMoreResultView(dataAdapter: dataAdapter)
            
        default/*case .loadMoreStub*/:
            showLoadMoreStubView(dataAdapter: dataAdapter)
        }
    }
    
    func showLoadMoreEmptyResultView(dataAdapter: DataAdapter) {
        //print("PaginatedScreenPresenter.willShowLoadMoreEmptyResultView()")
        
        willShowLoadMoreEmptyResultView?(dataAdapter: dataAdapter)
        
        paginationView.hideLoadingView()
    }
    
    func showLoadMoreErrorConnectionView(dataAdapter: DataAdapter) {
        //print("PaginatedScreenPresenter.willShowLoadMoreErrorConnectionView()")
        
        willShowLoadMoreErrorConnectionView?(dataAdapter: dataAdapter)
        
        paginationView.hideLoadingView()
    }
    
    func showLoadMoreResultView(dataAdapter: DataAdapter) {
        //print("PaginatedScreenPresenter.willShowLoadMoreResultView()")
        
        willShowLoadMoreResultView?(dataAdapter: dataAdapter)
        
        paginationView.showLoadingView()
    }
    
    func showLoadMoreStubView(dataAdapter: DataAdapter) {
        //print("PaginatedScreenPresenter.willShowLoadMoreStubView()")
        
        willShowLoadMoreStubView?(dataAdapter: dataAdapter)
        
        paginationView.showLoadingView()
    }
}
