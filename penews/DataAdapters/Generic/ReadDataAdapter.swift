//
//  ReadDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class ReadDataAdapter<T: Mappable>: DataAdapter {
    
    // MARK: - Properties
    
    var isLoading = false
    var request: URLRequestConvertible?
    
    
    // MARK: - Methods
    
    func didUpdateResponse(_ response: DataResponse<T>?) {
        //print("ReadDataAdapter.didUpdateResponse()")
    }
    
    func load() {
        
        guard let request = request else {
            return
        }
        
        isLoading = true
        Alamofire.request(request)
            .validate().responseObject { [weak self] (response: DataResponse<T>) in
                
                self?.isLoading = false
                self?.didUpdateResponse(response)
        }
    }
}
