//
//  MoviesVC.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit
import Combine
import CombineDataSources
import SwiftyMediaGallery
import CombineCocoa

class MoviesVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var lblNoMovies: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var actInd: UIActivityIndicatorView!
    
    private var viewModel : MoviesListViewModelProtocol!
    private var subscriptions = [AnyCancellable]()
    private var withSearchBar = false

    class func getVC(viewModel:MoviesListViewModelProtocol, withSearchBar: Bool) -> MoviesVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MoviesVC") as! MoviesVC
        vc.viewModel = viewModel
        vc.withSearchBar = withSearchBar
        return vc
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = !withSearchBar
        bind();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    private func bind(){
        searchBar.textDidChangePublisher.debounce(for:1,scheduler: RunLoop.main).sink { [weak self](query) in
            self?.viewModel.fetchMovies(query: query)
        }.store(in: &subscriptions)
        
        viewModel.arrMoviesItems.receive(on: DispatchQueue.main).bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: "MovieCell", cellType: MovieCell.self, cellConfig: { cell, indexPath, movie in
            cell.setup(movie: movie)
        })).store(in: &subscriptions)
        
        viewModel.arrMoviesItems
            .receive(on: DispatchQueue.main)
            .map{$0.count != 0}
            .sink(receiveValue: { [weak self] (hide) in
                self?.lblNoMovies.isHidden = hide
            })
            .store(in: &subscriptions)
        
        viewModel.downloading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (loading) in
                self?.actInd.isHidden  = !loading
                self?.view.isUserInteractionEnabled  = !loading
            })
            .store(in: &subscriptions)
    }

}

extension MoviesVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.viewModel.arrMoviesItems.value[indexPath.row]
        let vc = MovieDetailsVC.getVC(viewModel: MovieDetailsViewModel.create(from: movie))
        self.present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.arrMoviesItems.value.count - 5{
            viewModel.fetchMovies(query: nil)
        }
    }
}

extension MoviesVC: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.width)
        return CGSize(width:width , height:280)
    }
}

