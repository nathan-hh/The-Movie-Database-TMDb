//
//  UserVC.swift
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

class UserVC: UIViewController {

    @IBOutlet var actInd: UIActivityIndicatorView!
    @IBOutlet var imgAvatar: UIImageView!
    @IBOutlet var TFname: UITextField!
    @IBOutlet var TFpass: UITextField!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblName: UILabel!
    
    @IBOutlet var lblLang: UILabel!
    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var SVlogin: UIStackView!
    @IBOutlet var btnLoginLogout: UIButton!
    @IBOutlet var SVuserDetails: UIStackView!
    
    private var viewModel = UserViewModel()
    private var subscriptions = [AnyCancellable]()

    class func getVC(viewModel:UserViewModel) -> UserVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserVC") as! UserVC
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    private func bind(){
        viewModel.user.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (user) in
                self?.lblName.text = user?.name
                self?.lblUserName.text = user?.username
                self?.lblCountry.text = user?.iso31661
                self?.lblLang.text = user?.iso6391
                let url = "http://www.gravatar.com/avatar/\(user?.avatar?.avatarHash)"
                self?.imgAvatar.set(image:url)
            })
            .store(in: &subscriptions)
        
        viewModel.downloading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (loading) in
                self?.actInd.isHidden  = !loading
                self?.view.isUserInteractionEnabled  = !loading
            })
            .store(in: &subscriptions)
        
        viewModel.loggedIn
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (logged) in
                self?.SVuserDetails.isHidden = !logged
                self?.SVlogin.isHidden = logged
                self?.imgAvatar.isHidden = !logged
                self?.btnLoginLogout.setTitle(logged ? "LogOut" : "Login", for: .normal)
            })
            .store(in: &subscriptions)
        
        viewModel.logErr
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (err) in
                guard let err = err else {return}
                let alert = UIAlertController(title: "Error", message:err, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .store(in: &subscriptions)
    }

    @IBAction func buttonLogin(_ sender: UIButton) {
        if viewModel.loggedIn.value{
            viewModel.logOut()
        }else{
            viewModel.login(name: TFname.text!, pass: TFpass.text!)
        }
    }
}
