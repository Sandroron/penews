//
//  ArticleTableViewCell.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import AlamofireImage
import UIKit

final class ArticleTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var likeButton: LikeButton!
    
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        articleImageView.layer.cornerRadius = 4.0
    }
    
    
    // MARK: - Methods
    
    func setup(withArticle article: Article?, isLiked: Bool) {
        
        guard let article = article else { return }
        
        sourceLabel.text = article.source?.name ?? "Unknown source"
        titleLabel.text = article.title ?? "No title"
        descriptionLabel.text = article.description ?? ""
        
        if let author = article.author {
            
            authorLabel.text = "by \(author)"
        } else {
            
            authorLabel.text = nil
        }
        
        articleImageView.image = nil
        
        if let imageString = article.urlToImage,
            let imageUrl = URL(string: imageString) {
            
            articleImageView.af_setImage(withURL: imageUrl)
            articleImageView.isHidden = false
        } else {
            
            articleImageView.isHidden = true
        }
        
        likeButton.isLiked = isLiked
    }
}
