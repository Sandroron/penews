//
//  ArticleListDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import Foundation

class ArticleListDataAdapter: PaginatedListDataAdapter<ScreenPresenter, Article, WrapperArticles<Article>> {
    
    
    // MARK: - Methods
    
    func configure(q: String? = nil, filter: ArticleListFilter? = nil, sortBy: String? = nil) {
        
        if let sortBy = sortBy,
           let sources = filter?.sources {
            
            request = Router.everything(q: q,
                                        sources: sources,
                                        sortBy: sortBy)
        } else {
            
            // Note: you can't mix sources param with the country or category params.
            if let sources = filter?.sources {
                
                request = Router.topHeadlines(q: q,
                                              sources: sources)
            } else {
                
                request = Router.topHeadlines(q: q,
                                              country: filter?.country,
                                              category: filter?.category)
            }
        }
    }
}
