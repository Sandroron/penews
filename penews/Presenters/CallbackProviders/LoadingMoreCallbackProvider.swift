//
//  LoadingMoreCallbackProvider.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper
import UIKit

@objc protocol LoadingMoreCallbackProvider {
    
    // MARK: - Optional methods
    
    @objc optional func willShowLoadMoreEmptyResultView(dataAdapter: DataAdapter)
    @objc optional func willShowLoadMoreErrorConnectionView(dataAdapter: DataAdapter)
    @objc optional func willShowLoadMoreResultView(dataAdapter: DataAdapter)
    @objc optional func willShowLoadMoreStubView(dataAdapter: DataAdapter)
}
