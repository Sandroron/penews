//
//  Article.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper

class Article: Mappable {
    
    // MARK: - Static constants
    
    static let f_author         = "author"
    static let f_title          = "title"
    static let f_description    = "description"
    static let f_url            = "url"
    static let f_urlToImage     = "urlToImage"
    static let f_publishedAt    = "publishedAt"
    static let f_content        = "content"
    
    static let f_source         = "source"
    
    
    // MARK: - Properties
    
    var author:                 String?
    var title:                  String?
    var description:            String?
    var url:                    String?
    var urlToImage:             String?
    var publishedAt:            String?
    var content:                String?
    
    var source:                 Source?
    
    
    // MARK: - Inits
    
    init(author: String?, title: String?, description: String?, url: String?, urlToImage: String?, publishedAt: String?, content: String?, source: Source?) {
        
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
        self.source = source
    }
    
    
    // MARK: - Mappable
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        author                  <- map[Article.f_author]
        title                   <- map[Article.f_title]
        description             <- map[Article.f_description]
        url                     <- map[Article.f_url]
        urlToImage              <- map[Article.f_urlToImage]
        publishedAt             <- map[Article.f_publishedAt]
        content                 <- map[Article.f_content]
        
        source                  <- map[Article.f_source]
    }
    
    
    // MARK: - Methods
    
    func asLocal() -> ArticleLocal {
        
        let articleLocal = ArticleLocal()
        articleLocal.author = author ?? ""
        articleLocal.title = title ?? ""
        articleLocal.descr = description ?? ""
        articleLocal.url = url ?? ""
        articleLocal.urlToImage = urlToImage ?? ""
        articleLocal.publishedAt = publishedAt ?? ""
        articleLocal.content = content ?? ""
        articleLocal.sourceName = source?.name ?? ""
        
        return articleLocal
    }
}
