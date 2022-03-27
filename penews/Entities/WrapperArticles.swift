//
//  WrapperArticles.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper

class WrapperArticles<T: Mappable>: Wrapper<T> {
    
    // MARK: - Fields
    
    let f_data          = "articles"
    
    
    // MARK: - Mappable
    
    override func mapping(map: Map) {
        
        count           <- map[f_count]
        data            <- map[f_data]
    }
}
