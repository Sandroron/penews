//
//  LoadingViewProvider.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

@objc protocol LoadingViewProvider {
    
    // MARK: - Properties
    
    var emptyResultView:        UIView! { get }
    var errorConnectionView:    UIView! { get }
    var resultView:             UIView! { get }
    var stubView:               UIView! { get }
}
