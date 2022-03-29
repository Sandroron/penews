//
//  LoadingStateManager.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import RxSwift
import RxCocoa

class LoadingStateManager<P: NoViewLoadingPresenter> {
    
    // MARK: - Properties
    
    private(set) var state: BehaviorRelay<LoadingState>
    
    
    // MARK: - Private properties
    
    private var dataAdapter: DataAdapter?
    private var presenter: P
    private var changingStateSubscription: Disposable?
    
    
    // MARK: - Inits
    
    init(presenter: P, state: LoadingState = .stub) {
        self.presenter = presenter
        self.state = BehaviorRelay(value: state)
    }
    
    
    // MARK: - Methods
    
    func startListening(dataAdapter: DataAdapter) {
        //print("LoadingStateManager.startListening()")
        
        self.dataAdapter = dataAdapter
        
        changingStateSubscription = state.asObservable().subscribe(onNext: { [weak self] state in
            self?.didUpdateState(state)
        })
    }
    
    func stopListening() {
        //print("LoadingStateManager.stopListening()")
        
        changingStateSubscription?.dispose()
        changingStateSubscription = nil
        
        dataAdapter = nil
    }
    
    
    // MARK: - Private methods
    
    private func didUpdateState(_ state: LoadingState) {
        //print("LoadingStateManager.didUpdateState(state: \(state))")
        
        guard let dataAdapter = dataAdapter else {
            return
        }
        
        // https://medium.com/@m.muizzsuddin_25037/override-protocol-extension-default-implementation-in-swift-969753f4b11b
        if let screenPresenter = presenter as? ScreenPresenter {
            
            screenPresenter.setLoadingState(state, dataAdapter: dataAdapter)
        } else {
            presenter.setLoadingState(state, dataAdapter: dataAdapter)
        }
    }
}
