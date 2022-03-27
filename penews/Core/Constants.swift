//
//  Constants.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

enum Api {
    
    static let baseUrl = "https://newsapi.org/v2"
    static let apiKey = "061d676e983b4cde92e7878f9755ee50" // db058b3eb34b4ec8949638fb7e639171
}

enum LoadingState {
    
    case empty
    case error
    case result
    case stub
}

enum LoadingMoreState {
    
    case loadMoreEmpty
    case loadMoreError
    case loadMoreResult
    case loadMoreStub
}

enum Nib {
    
    static var paginationView: UINib { get { return UINib(nibName: "PaginationView", bundle: nil) }}
}
