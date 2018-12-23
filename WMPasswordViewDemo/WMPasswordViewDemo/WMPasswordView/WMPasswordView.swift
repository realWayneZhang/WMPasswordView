//
//  PasswordView.swift
//  RefuelNow
//
//  Created by Winson Zhang on 2018/12/21.
//  Copyright © 2018 LY. All rights reserved.
//

import UIKit

let wm_screenWidth = UIScreen.main.bounds.width
let wm_screenHeight = UIScreen.main.bounds.height

enum WMPwdType: String {
    case setPwd = "设置支付密码"
    case payPwd = "输入支付密码"
}
/**
 可以使用类方法调用，一行代码
 可以使用实例方法，需要设置完成回调 Closure
 */

final class WMPasswordView {
    
    fileprivate var type: WMPwdType
    fileprivate var amount: Double?
    var completed:((_ pwd: String) -> Void)?
    
    /// passwordView
    lazy var pwdView: PasswordView = {
        return Bundle.main.loadNibNamed("PasswordView", owner: nil, options: nil)?.first as! PasswordView
    }()
    /// 遮罩层
    lazy var maskView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(patternImage: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).image!)
        return view
    }()
    
    /// 可以使用实例方法, 要设置 完成设置回调Closure
    init(type: WMPwdType, amount: Double? = nil) {
        self.type = type
        self.amount = amount
        var tempFrame = pwdView.frame
        tempFrame.size.width = wm_screenWidth
        pwdView.frame = tempFrame
        maskView.addSubview(pwdView)
         pwdView.center = CGPoint(x: maskView.center.x, y: maskView.center.y * 3 / 4)
        pwdView.titleLabel.text = type.rawValue
        if type == .payPwd { pwdView.amountLabel.text = "支付金额: " + String(format: "%.2f元", amount!) }
        pwdView.completed = { [weak self] pwd in self?.dismiss() ; self?.completed?(pwd) }
        pwdView.cancel = { [weak self] in self?.dismiss() }
    }
    
    /// 显示
    func show() {
        pwdView.reset()
        UIApplication.shared.keyWindow?.addSubview(maskView)
        pwdView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        maskView.alpha = 1
        maskView.backgroundColor = UIColor(patternImage: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).image!)
        pwdView.alpha = 0
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { [weak self] in
                        self?.pwdView.pwdTextField.becomeFirstResponder()
                        self?.pwdView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self?.pwdView.alpha = 1
                        // self?.maskView.layoutIfNeeded()
        }) { (_) in
        }
    }
    
    /// 消失
    fileprivate func dismiss() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.pwdView.pwdTextField.resignFirstResponder()
            self?.maskView.alpha = 0
            self?.pwdView.alpha = 0
        }) { [weak self] (_) in
            self?.maskView.removeFromSuperview()
        }
    }
    
    /// 可是使用类方法调用 一句代码调用
    class func show(type: WMPwdType, amount: Double?, completed:@escaping (_ pwd: String) -> Void) {
        let shared = WMPasswordView (type: type, amount: amount)
        shared.pwdView.completed = { pwd in shared.dismiss() ; completed(pwd) }
        shared.pwdView.cancel = { shared.dismiss() ; print(Unmanaged.passUnretained(shared).toOpaque())}
        shared.show()
    }
}

final class PasswordView: UIView {

    /// 背景view
    @IBOutlet weak var backgroundView: UIView!
    /// 标题 label
    @IBOutlet weak var titleLabel: UILabel!
    /// 金额 label
    @IBOutlet weak var amountLabel: UILabel!
    /// 支付密码的 backgroundview
    @IBOutlet weak var pwdBackgroundView: UIView!
    /// 密码输入框
    @IBOutlet weak var pwdTextField: UITextField!
    /// 取消按钮
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var circle1: UILabel!
    @IBOutlet weak var circle2: UILabel!
    @IBOutlet weak var circle3: UILabel!
    @IBOutlet weak var circle4: UILabel!
    @IBOutlet weak var circle5: UILabel!
    @IBOutlet weak var circle6: UILabel!
    
    typealias Circle = UILabel
    var circles: [Circle] = []
    var completed:((_ pwd: String) -> Void)?
    var cancel:(() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - 设置 UI
extension PasswordView {
    fileprivate func setupUI() {
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 5
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = cancelButton.frame.height * 0.5
        pwdTextField.delegate = self
        pwdTextField.addTarget(self, action: #selector(textChanging(tf:)), for: UIControl.Event.editingChanged)
        setShadow(view: pwdBackgroundView)
        circles = [circle1, circle2, circle3, circle4, circle5, circle6]
        _ = circles.map{
            $0.layer.cornerRadius = $0.frame.height * 0.5
            $0.layer.masksToBounds = true
            $0.isHidden = true
        }
    }
    
    /// 按钮点击事件
    @IBAction func cancelButtonClicked() { cancel?() }
    
    @objc func textChanging(tf: UITextField) {
        guard let text = tf.text else { return }
        if text.count > 6 { return }
        if text.count >= 0 { setupCircles(index: text.count) }
        if tf.text?.count == 6 { completed?(pwdTextField.text!) }
    }
}

// MARK: - 代理事件
extension PasswordView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return (textField.text?.count ?? 0) < 6
    }
    /// 设置 圆点
    fileprivate func setupCircles(index: Int) {
        _ = circles.map{ $0.isHidden = true }
        for  i in 0..<index { circles[i].isHidden = false }
    }
}

// MARK: - 重置 pwd view
extension PasswordView {
    fileprivate func reset() {
        _ = circles.map{ $0.isHidden = true }
        pwdTextField.text = nil
        pwdTextField.resignFirstResponder()
    }
}

// MARK: - 设置阴影
extension PasswordView {
    func setShadow (view: UIView) {
        let hexColor: __uint32_t = 0xF9DB50
        let r: __uint8_t = __uint8_t((hexColor & 0xff0000) >> 16);
        let g: __uint8_t = __uint8_t((hexColor & 0x00ff00) >> 8);
        let b: __uint8_t = __uint8_t(hexColor & 0x0000ff);
        let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
        let offSet = CGSize(width: 0, height: 0);
        let layer = view.layer
        layer.shadowOffset = offSet
        layer.shadowRadius = 2
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.5
    }
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        if #available(iOS 10.0, *) { self.init(displayP3Red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a) }
        else { self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a) }
    }
    
    var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(self.cgColor)
        ctx?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
