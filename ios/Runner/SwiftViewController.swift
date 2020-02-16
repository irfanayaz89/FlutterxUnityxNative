//
//  SwiftViewController.swift
//  Runner
//
//  Created by Irfan Ayaz on 11/02/2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit


class SwiftViewController: UIViewController {
    
    var callback : (() -> Void)? = nil
        
    @IBAction func unityBtnPressed(_ sender: Any) {
        UnityEmbeddedSwift.showUnity()
    }
    
    @IBAction func unloadUnityView(_ sender: Any) {
        UnityEmbeddedSwift.unloadUnity()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            guard let dismissCallback = self.callback else { return }
            dismissCallback()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
       super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }
    
    func changeBackground(color: String) {
        if (color == "blue") {
            self.view.backgroundColor = UIColor.blue
        } else if (color == "red") {
            self.view.backgroundColor = UIColor.red
        } else if (color == "yellow") {
            self.view.backgroundColor = UIColor.yellow
        } else {
            self.view.backgroundColor = UIColor.darkGray
        }
    }
    
}
