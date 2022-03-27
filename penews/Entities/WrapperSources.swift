//
//  WrapperSources.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper

class WrapperSources<T: Mappable>: Wrapper<T> {
    
    // MARK: - Fields
    
    let f_data          = "sources"
    
    
    // MARK: - Mappable
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        data            <- map[f_data]
    }
}
