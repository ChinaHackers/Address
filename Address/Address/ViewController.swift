//
//  ViewController.swift
//  Address
//
//  Created by Liu Chuan on 16/9/11.
//  Copyright © 2016年 LC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addressButton: UIButton!  // 选择地址按钮

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressButton.addTarget(self, action: #selector(selectAddress), for: .touchUpInside)

        
    }
    
    // MARK: - 选择地址按钮点击事件
    @objc fileprivate func selectAddress() {
        
        let addressVC = AddressViewController()
        let naVC = UINavigationController(rootViewController: addressVC)
        self.present(naVC, animated: true, completion: nil)
    }
}

