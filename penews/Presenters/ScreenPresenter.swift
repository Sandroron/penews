//
//  ScreenPresenter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

@objc protocol ScreenPresenter: NoViewLoadingPresenter, LoadingViewProvider {
}

extension ScreenPresenter {
    
    func setLoadingState(_ loadingState: LoadingState, dataAdapter: DataAdapter) {
        //print("ScreenPresenter.setLoadingState(loadingState: \(loadingState))")
        
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
        //print("ScreenPresenter.showEmptyResultView()")
        
        emptyResultView.isHidden = false
        errorConnectionView.isHidden = true
        resultView.isHidden = true
        stubView.isHidden = true
        
        willShowEmptyResultView?(dataAdapter: dataAdapter)
    }

    func showErrorConnectionView(dataAdapter: DataAdapter) {
        //print("ScreenPresenter.showErrorConnectionView()")
        
        emptyResultView.isHidden = true
        errorConnectionView.isHidden = false
        resultView.isHidden = true
        stubView.isHidden = true
        
        willShowErrorConnectionView?(dataAdapter: dataAdapter)
    }
    
    func showResultView(dataAdapter: DataAdapter) {
//        print("ScreenPresenter.showResultView()")
        
        emptyResultView.isHidden = true
        errorConnectionView.isHidden = true
        resultView.isHidden = false
        stubView.isHidden = true
        
        willShowResultView?(dataAdapter: dataAdapter)
    }
    
    func showStubView(dataAdapter: DataAdapter) {
        //print("ScreenPresenter.showStubView()")
        
        emptyResultView.isHidden = true
        errorConnectionView.isHidden = true
        resultView.isHidden = true
        stubView.isHidden = false
        
        willShowStubView?(dataAdapter: dataAdapter)
    }
}
