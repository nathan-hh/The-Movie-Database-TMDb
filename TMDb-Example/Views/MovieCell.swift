//
//  MovieCell.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var backImage: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var rateTitle: UILabel!
    @IBOutlet var lblOverview: UILabel!

    private var movie:Movie!
    
    func setup(movie:Movie) {
        self.movie = movie
        img.set(image: movie.posterUrl)
        backImage.set(image: movie.backdropPathUrl)
        lblTitle.text = movie.title
        lblOverview.text = movie.overview
        rateTitle.text = "Rank: \(movie.voteAverage)"
    }
    
}
