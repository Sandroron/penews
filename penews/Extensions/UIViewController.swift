//
//  UIViewController.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

extension UIViewController {
    
    // MARK: - Static methods
    
    static func loadFromNib() -> Self {
        
        func instantiateFromNib<T: UIViewController>() -> T {
            
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
}
