//
//  File.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import UIKit


class AppTabBarVC: UITabBarController ,UITabBarControllerDelegate{
    class func getVC() -> AppTabBarVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AppTabBarVC") as! AppTabBarVC
        vc.delegate = vc
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTabbar();
    }
    
    func setTabbar(){
        let popular = MoviesVC.getVC(viewModel: MoviesListViewModel(), withSearchBar: false)
        popular.tabBarItem = UITabBarItem(title: "popular", image:  UIImage(named: "tab_movies")?.withRenderingMode(.alwaysOriginal), selectedImage: nil)

        let search = MoviesVC.getVC(viewModel: SearchViewModel(), withSearchBar: true)
        search.tabBarItem = UITabBarItem(title: "search", image:  UIImage(named: "tab_watchlist")?.withRenderingMode(.alwaysOriginal), selectedImage: nil)
        let login = UserVC.getVC(viewModel: UserViewModel())
        login.tabBarItem = UITabBarItem(title: "user", image:  UIImage(named: "tab_user")?.withRenderingMode(.alwaysOriginal), selectedImage: nil)

        let tabBarList = [popular,search,login]

        viewControllers = tabBarList
    }

}
