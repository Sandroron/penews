//
//  ListDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 27.03.2022.
//

import Alamofire
import ObjectMapper
import RxSwift

class ListDataAdapter<P: NoViewLoadingPresenter, T: Mappable, W: Wrapper<T>>: ReadDataAdapter<W> {
    
    // MARK: - Properties
    
    var clearObjectOnFailure = false
    var keepOldObjects = false
    var data = String()
    
    
    // MARK: - Properties (Data)
    
    /* TODO: private(set) */var objects: [T]?
    
    
    // MARK: - Private properties
    
    private var stateManager: LoadingStateManager<P>
    
    
    // MARK: - Inits
    
    init(presenter: P, state: LoadingState = .stub) {
        self.stateManager = LoadingStateManager<P>(presenter: presenter, state: state)
        super.init()
    }
    
    
    // MARK: - Override methods
    
    override func didUpdateResponse(_ response: DataResponse<W>?) {
        
        // The download didn't even start (probably due to invalid input data).
        // In this case, you need to show an empty state (404).
        if request == nil {
            
            stateManager.state.accept(.empty)
            return
        }
        
        // Loading has not completed yet, need to show the stub.
        if isLoading {
            
            stateManager.state.accept(.stub)
            return
        }
        
        // Loading completed, results/errors can be displayed
        if let wrapperC = response?.result.value {
            
            if let objects = wrapperC.data,
               objects.count != 0 {
                
                if keepOldObjects && self.objects != nil {
                    self.objects!.append(contentsOf: objects)
                } else {
                    self.objects = objects
                }
                
                stateManager.state.accept(.result)
            } else {
                clearObjectIfNeeded()
                stateManager.state.accept(.empty)
            }
            
        } else {
            
            clearObjectIfNeeded()
            stateManager.state.accept(.error)
        }
    }
    
    
    // MARK: - Methods
    
    func startListening() {
        
        stateManager.startListening(dataAdapter: self)
    }
    
    func stopListening() {
        
        stateManager.stopListening()
    }
    
    
    // MARK: - Private methods
    
    private func clearObjectIfNeeded() {
        if clearObjectOnFailure {
            objects = nil
        }
    }
}
