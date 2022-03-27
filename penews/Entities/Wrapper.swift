//
//  Wrapper.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 28.03.2022.
//

import ObjectMapper

class Wrapper<T: Mappable>: Mappable {
    
    // MARK: - Fields
    
    let f_count         = "totalResults"
    
    
    // MARK: - Properties
    
    var count: Int?
    var data: [T]?
    
    
    // MARK: - Inits
    
    init(data: [T]?, count: Int? = nil) {
        
        self.count = count
        self.data = data
    }
    
    
    // MARK: - Mappable
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        count           <- map[f_count]
    }
}
