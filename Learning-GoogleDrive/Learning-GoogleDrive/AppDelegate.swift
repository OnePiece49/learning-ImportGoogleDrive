//
//  AppDelegate.swift
//  Learning-GoogleDrive
//
//  Created by Tiến Việt Trịnh on 11/08/2023.
//

import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance().clientID = "694744306951-h2k1qjqhtqj2nhd5c21vq0cthtph92vd.apps.googleusercontent.com"
        
        return true
    }



}



