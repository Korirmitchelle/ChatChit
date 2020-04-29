//
//  ChatPresenter.swift
//  SendBirdUIKit-Sample
//
//  Created by Mitch on 29/04/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//
import SendBirdUIKit
import Foundation
import UIKit

class Presenter{
    func present(viewController:UIViewController, userId:String, nickName:String){
        SBUGlobals.CurrentUser = SBUUser(userId: userId, nickname: nickName)
        SBUMain.connect { user, error in
            if let user = user {
                UserDefaults.standard.set(userId, forKey: "user_id")
                UserDefaults.standard.set(nickName, forKey: "nickname")
                print("SBUMain.connect: \(user)")
                SBUTheme.set(theme:.light)
                let channelListVC = SBUChannelListViewController()
                let naviVC = UINavigationController(rootViewController: channelListVC)
                naviVC.modalPresentationStyle = .fullScreen
                viewController.present(naviVC, animated: true)
            }
        }
        
    }
}
