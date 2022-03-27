//
//  DataBaseManager.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 27.03.2022.
//

import RealmSwift

class DataBaseManagerImplementation: DataBaseManager {
    
    // MARK: - Properties
    
    fileprivate lazy var mainRealm = try! Realm(configuration: .defaultConfiguration)
    
    
    // MARK: - Methods
    
    func save(article: Article?) {
        
        guard let article = article else { return }
        
        if let localArticle = mainRealm.object(ofType: ArticleLocal.self, forPrimaryKey: article.url) {
            
            try! mainRealm.write {
                
                mainRealm.delete(localArticle)
            }
        } else {
            
            try! mainRealm.write {
                
                mainRealm.add(article.asLocal())
            }
        }
    }
    
    func isLiked(article: Article?) -> Bool {
        
        return mainRealm.object(ofType: ArticleLocal.self, forPrimaryKey: article?.url) != nil
    }
    
    func obtainArticles() -> [Article?] {
        
        return mainRealm.objects(ArticleLocal.self).map({ $0.asApi() })
    }
}

protocol DataBaseManager {
    
    func save(article: Article?)
    func obtainArticles() -> [Article?]
}

