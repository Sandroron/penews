//
//  LoadingCallbackProvider.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper
import UIKit

@objc protocol LoadingCallbackProvider {
    
    // MARK: - Optional methods
    
    @objc optional func willShowEmptyResultView(dataAdapter: DataAdapter)
    @objc optional func willShowErrorConnectionView(dataAdapter: DataAdapter)
    @objc optional func willShowResultView(dataAdapter: DataAdapter)
    @objc optional func willShowStubView(dataAdapter: DataAdapter)
}
