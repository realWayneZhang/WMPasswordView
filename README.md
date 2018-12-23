# WMPasswordView
Swift4.2 仿微信、支付宝输入支付密码

![效果展示](https://github.com/WinsonCheung/WMPasswordView/blob/master/WMPasswordView.gif)

# Usage
把WMPasswordView文件夹拖入项目中，
代码如下：
```swift
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
```

### 如果对您有帮助，请给个Star！😄，Thank you for look！
