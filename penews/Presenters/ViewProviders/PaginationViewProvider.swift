//
//  PaginationViewProvider.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

@objc protocol PaginationViewProvider {
    
    // MARK: - Properties
    
    var paginationView: PaginationView! { get }
}
