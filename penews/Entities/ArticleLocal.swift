//
//  ArticleLocal.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 27.03.2022.
//

import RealmSwift

@objcMembers
class ArticleLocal: Object {
    
    // MARK: - Properties
    
    dynamic var author          = String()
    dynamic var title           = String()
    dynamic var descr           = String()
    dynamic var url             = String()
    dynamic var urlToImage      = String()
    dynamic var publishedAt     = String()
    dynamic var content         = String()
    dynamic var sourceName      = String()
    
    override class func primaryKey() -> String? {
        
        return #keyPath(url) // ID
    }
    
    
    // MARK: - Methods
    
    func asApi() -> Article {
        
        return Article(author: author,
                       title: title,
                       description: descr,
                       url: url,
                       urlToImage: urlToImage,
                       publishedAt: publishedAt,
                       content: content,
                       source: Source(name: sourceName,
                                      id: nil))
    }
}
