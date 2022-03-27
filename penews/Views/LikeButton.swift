//
//  LikeButton.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 27.03.2022.
//

import UIKit

class LikeButton: UIButton {
    
    // MARK: - Open properties
    
    var isLiked:        Bool = false      { didSet { setup() } }
    var indexPath:      IndexPath?
    
    
    // MARK: - Override inits
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    // MARK: - Private methods
    
    private func setup() {
        
        setTitle("", for: .normal)
        
        if isLiked {
            
            setImage(UIImage(named: "heart_filled_24pt"), for: .normal)
        } else {
            
            setImage(UIImage(named: "heart_outline_24pt"), for: .normal)
        }
    }
}
