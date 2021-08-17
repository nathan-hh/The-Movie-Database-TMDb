//
//  MovieDetailsVC.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit
import WebKit
import Combine
import CombineCocoa

class MovieDetailsVC: UIViewController {

    private var viewModel : MovieDetailsViewModel!
    private var subscriptions = [AnyCancellable]()

    @IBOutlet var lblRelease: UILabel!
    @IBOutlet var lblGeners: UILabel!
    @IBOutlet var lblRevenue: UILabel!
    @IBOutlet var lblBudget: UILabel!
    @IBOutlet var imgMovie: UIImageView!
    @IBOutlet var txtDesc: UILabel!
    
    class func getVC(viewModel:MovieDetailsViewModel) -> MovieDetailsVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as! MovieDetailsVC
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.loadDetails()
    }
    
    func bind(){
        viewModel.movie
            .receive(on:DispatchQueue.main)
            .sink(receiveValue: {[weak self] (movie) in
                guard let self = self , let movie = movie  else {return}
                self.imgMovie.set(image: movie.posterUrl)
                self.txtDesc.text = movie.overview
                self.lblGeners.text = movie.genresDisplay
                self.lblBudget.text =  String(movie.budget ?? 0)
                self.lblRevenue.text = String(movie.revenue ?? 0)
                self.lblRelease.text = movie.releaseDate
            }).store(in: &subscriptions)
    }
    
}
