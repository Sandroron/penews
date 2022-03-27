//
//  NoViewLoadingPresenter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import Foundation

@objc protocol NoViewLoadingPresenter: LoadingCallbackProvider {
}

extension NoViewLoadingPresenter {
    
    func setLoadingState(_ loadingState: LoadingState, dataAdapter: DataAdapter) {
        //print("NoViewLoadingPresenter.setLoadingState(loadingState: \(loadingState))")
        
        switch loadingState {
            
        case .empty:
            showEmptyResultView(dataAdapter: dataAdapter)
            
        case .error:
            showErrorConnectionView(dataAdapter: dataAdapter)
            
        case .result:
            showResultView(dataAdapter: dataAdapter)
            
        default:
            showStubView(dataAdapter: dataAdapter)
        }
    }
    
    func showEmptyResultView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingPresenter.showEmptyResultView()")
        willShowEmptyResultView?(dataAdapter: dataAdapter)
    }
    
    func showErrorConnectionView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingPresenter.showErrorConnectionView()")
        willShowErrorConnectionView?(dataAdapter: dataAdapter)
    }
    
    func showResultView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingPresenter.showResultView()")
        willShowResultView?(dataAdapter: dataAdapter)
    }
    
    func showStubView(dataAdapter: DataAdapter) {
        //print("NoViewLoadingPresenter.showStubView()")
        willShowStubView?(dataAdapter: dataAdapter)
    }
}
