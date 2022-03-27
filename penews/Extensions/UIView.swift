//
//  UIView.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import UIKit

extension UIView {
    
    // MARK: - Static methods
    
    static func loadFromNib() -> Self {
        
        func instantiateFromNib<T: UIView>() -> T {
            
            return UINib(nibName: String(describing: T.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! T
        }
        
        return instantiateFromNib()
    }
}
