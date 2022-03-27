//
//  Source.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper

class Source: Mappable, ApiName {
    
    func getApiName() -> String {
        
        return "sources"
    }
    
    
    // MARK: - Static constants
    
    static let f_id             = "id"
    static let f_name           = "name"
    static let f_description    = "description"
    static let f_url            = "url"
    static let f_category       = "category"
    static let f_language       = "language"
    static let f_country        = "country"
    
    
    // MARK: - Properties
    
    var id:                     String?
    var name:                   String?
    var description:            String?
    var url:                    String?
    var category:               String?
    var language:               String?
    var country:                String?
    
    
    // MARK: - Inits
    
    init(name: String?, id: String?) {
        
        self.name = name
        self.id = id
    }
    
    
    // MARK: - Mappable
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                  <- map[Source.f_id]
        name                <- map[Source.f_name]
        description         <- map[Source.f_description]
        url                 <- map[Source.f_url]
        category            <- map[Source.f_category]
        language            <- map[Source.f_language]
        country             <- map[Source.f_country]
    }
}

protocol ApiName {
    
    func getApiName() -> String
}
