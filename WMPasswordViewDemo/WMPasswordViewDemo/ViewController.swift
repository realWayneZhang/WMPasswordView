//
//  ViewController.swift
//  WMPasswordViewDemo
//
//  Created by Winson Zhang on 2018/12/23.
//  Copyright © 2018 Winson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var payPwdLabel: UILabel!
    /// lazy load
    lazy var payPasswordView: WMPasswordView = {
        let pwdView = WMPasswordView(type: WMPwdType.payPwd, amount: 250.0)
        /// 回调 closure 可以在本类任意方法类写
        pwdView.completed = { [weak self] pwd in
            self?.payPwdLabel?.text = "输入的密码：" + pwd
        }
        return pwdView
    }()
    /// 类方法调用
    @IBAction func classFunction() {
        WMPasswordView.show(type: WMPwdType.payPwd, amount: 1200.0) { [weak self] pwd in
            self?.payPwdLabel?.text = "输入的密码：" + pwd
        }
    }
    /// 实例方法调用
    @IBAction func instanceFunction() {
        payPasswordView.show()
    }
}

