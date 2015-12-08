//
//  AppDelegate.swift
//  QSWaterFlowViewDemo
//
//  Created by zhangping on 15/12/8.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = QSWaterFlowViewDemoController()
        
        window?.makeKeyAndVisible()
        return true
    }

}

