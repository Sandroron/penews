//
//  LoadingMoreStateManager.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import RxSwift

class LoadingMoreStateManager<P: NoViewLoadingMorePresenter> {
    
    // MARK: - Properties
    
    // state обернут в Variable (RxSwift), чтобы можно было оформить подписку на его изменения
    private(set) var state: Variable<LoadingMoreState>
    
    
    // MARK: - Private properties
    
    private var dataAdapter: DataAdapter?
    private var presenter: P
    private var changingStateSubscription: Disposable?
    
    
    // MARK: - Inits
    
    init(presenter: P, state: LoadingMoreState = .loadMoreResult /*.stub*/) {
        self.presenter = presenter
        self.state = Variable(state)
    }
    
    
    // MARK: - Methods
    
    func startListening(dataAdapter: DataAdapter) {
        //print("LoadingMoreStateManager.startListening()")
        
        self.dataAdapter = dataAdapter
        
        changingStateSubscription = state.asObservable().subscribe(onNext: { [weak self] state in
            self?.didUpdateState(state)
        })
    }
    
    func stopListening() {
        //print("LoadingMoreStateManager.stopListening()")
        
        changingStateSubscription?.dispose()
        changingStateSubscription = nil
        
        dataAdapter = nil
    }
    
    
    // MARK: - Private methods
    
    private func didUpdateState(_ state: LoadingMoreState) {
        //print("LoadingMoreStateManager.didUpdateState()")
        
        guard let dataAdapter = dataAdapter else {
            return
        }
        
        // https://medium.com/@m.muizzsuddin_25037/override-protocol-extension-default-implementation-in-swift-969753f4b11b
        if let paginatedScreenPresenter = presenter as? PaginatedScreenPresenter {
            paginatedScreenPresenter.setLoadingMoreState(state, dataAdapter: dataAdapter)
            
        } else {
            presenter.setLoadingMoreState(state, dataAdapter: dataAdapter)
        }
    }
}
