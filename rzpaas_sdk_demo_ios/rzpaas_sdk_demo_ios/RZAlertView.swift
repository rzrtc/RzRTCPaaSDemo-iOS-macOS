//
//  RZAlertView.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/8.
//

import UIKit

class RZAlertView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var checkBtn: UIButton!
    
    
    var btnClick:(()->())?

    
    func btnClickDefault() {

    }
    
    
    @IBAction func onBtnClick(_ sender: Any) {
        (self.btnClick ?? btnClickDefault)()
        
    }
    
}
