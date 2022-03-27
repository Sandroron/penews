//
//  NoViewLoadingMorePresenter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

@objc protocol NoViewLoadingMorePresenter: LoadingMoreCallbackProvider {
}

extension NoViewLoadingMorePresenter {
    
    // MARK: - Methods
    
    func setLoadingMoreState(_ loadingMoreState: LoadingMoreState, dataAdapter: DataAdapter) {
        //print("NoViewLoadingMorePresenter.setLoadingMoreState(loadingMoreState: \(loadingMoreState))")
        
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
        //print("NoViewLoadingMorePresenter.willShowLoadMoreEmptyResultView()")
        willShowLoadMoreEmptyResultView?(dataAdapter: dataAdapter)
    }
    
    func showLoadMoreErrorConnectionView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingMorePresenter.willShowLoadMoreErrorConnectionView()")
        willShowLoadMoreErrorConnectionView?(dataAdapter: dataAdapter)
    }
    
    func showLoadMoreResultView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingMorePresenter.willShowLoadMoreResultView()")
        willShowLoadMoreResultView?(dataAdapter: dataAdapter)
    }
    
    func showLoadMoreStubView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingMorePresenter.willShowLoadMoreStubView()")
        willShowLoadMoreStubView?(dataAdapter: dataAdapter)
    }
}
