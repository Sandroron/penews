//
//  SourceListDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 27.03.2022.
//

import Foundation

class SourceListDataAdapter: ListDataAdapter<NoViewLoadingPresenter, Source, WrapperSources<Source>> {
    
    
    // MARK: - Methods
    
    func configure(category: String? = nil, country: String? = nil) {
        
        request = Router.sources(category: category,
                                 country: country)
    }
}
