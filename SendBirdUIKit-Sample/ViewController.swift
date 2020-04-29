

import UIKit
import SendBirdUIKit

enum ButtonType: Int {
    case signIn
    case startChat
    case signOut
}

class ViewController: UIViewController {
    
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var signInStackView: UIStackView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signOutStackView: UIStackView!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var lightThemeLabel: UILabel!
    @IBOutlet weak var darkThemeLabel: UILabel!
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.stopAnimating()
        }
    }
    
    let duration: TimeInterval = 0.4
    var isSignedIn = false {
        didSet {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.signInStackView.isHidden = self.isSignedIn
                self.signInStackView.alpha = self.isSignedIn ? 0 : 1
                self.signOutStackView.alpha = !self.isSignedIn ? 0 : 1
                self.signOutStackView.isHidden = !self.isSignedIn
            })
        }
    }
    
    var isLightTheme = true {
        didSet {
            let black = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.88)
            let blackGray = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38)
            let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.88)
            let whiteGray = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.38)
            
            setNeedsStatusBarAppearanceUpdate()
            titleLabel.changeColor(isLightTheme ? black : white, duration: duration)
            lightThemeLabel.changeColor(isLightTheme ? black : whiteGray, duration: duration)
            darkThemeLabel.changeColor(!isLightTheme ? white : blackGray, duration: duration)
            
            let color = isLightTheme ? UIColor.white : UIColor.black
            UIView.animate(withDuration: duration, animations: {
                self.view.backgroundColor = color
            })
            [userIdTextField ,nicknameTextField].forEach {
                $0?.backgroundColor = isLightTheme ? #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1) : #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 1)
                $0?.textColor = isLightTheme ? #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.88) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.88)
            }
            UIView.transition(with: startChatButton, duration: duration, options: .transitionCrossDissolve, animations: {
                self.signInButton.setTitleColor(color, for: .normal)
                self.startChatButton.setTitleColor(color, for: .normal)
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 12.0, *) {
            isLightTheme = traitCollection.userInterfaceStyle == .light
        }
        
        signInButton.tag    = ButtonType.signIn.rawValue
        startChatButton.tag = ButtonType.startChat.rawValue
        signOutButton.tag   = ButtonType.signOut.rawValue
        
        [signInButton, startChatButton, signOutButton].forEach {
            $0?.layer.cornerRadius = 4
            $0?.layer.borderColor = #colorLiteral(red: 0.4823529412, green: 0.3254901961, blue: 0.937254902, alpha: 1)
            $0?.layer.borderWidth = 1
        }
        
        signOutStackView.alpha = 0
        
        [userIdTextField, nicknameTextField].forEach {
            guard let textField = $0 else { return }
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.size.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            textField.tintColor = #colorLiteral(red: 0.4666666667, green: 0.337254902, blue: 0.8549019608, alpha: 1)
        }
        
        themeSwitch.tintColor = themeSwitch.onTintColor
        themeSwitch.layer.cornerRadius = themeSwitch.frame.height / 2
        themeSwitch.backgroundColor = themeSwitch.onTintColor
        versionLabel.text = "UI Kit v\(SBUMain.getUIKitVersion())     SDK \(SBDMain.getSDKVersion())"
        userIdTextField.text = UserDefaults.standard.string(forKey: "user_id")
        nicknameTextField.text = UserDefaults.standard.string(forKey: "nickname")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.logoStackView.isHidden = UIDevice.current.orientation.isLandscape
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return isLightTheme ? .darkContent : .lightContent
        } else {
            return isLightTheme ? .default : .lightContent
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            isLightTheme = traitCollection.userInterfaceStyle == .light
        }
    }
    
    // Action
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func onTapButton(_ sender: UIButton) {
        let type = ButtonType(rawValue: sender.tag)
        switch type {
            
        case .signIn:
            loadingIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            
            let userID = userIdTextField.text ?? ""
            let nickname = nicknameTextField.text ?? ""
            
            guard !userID.isEmpty else {
                userIdTextField.shake()
                userIdTextField.becomeFirstResponder()
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                return
            }
            guard !nickname.isEmpty else {
                nicknameTextField.shake()
                nicknameTextField.becomeFirstResponder()
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                return
            }
            Presenter().present(viewController: self, userId: userID, nickName: nickname)
            
        case .signOut:
            SBUMain.unregisterPushToken { success in
                SBUMain.disconnect {
                    print("SBUMain.disconnect")
                    self.isSignedIn = false
                }
            }
        default:
            break
            
        }
        view.layoutIfNeeded()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true

        
    }
    @IBAction func onEditingChangeTextField(_ sender: UITextField) {
        let color = sender.text?.isEmpty ?? true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : #colorLiteral(red: 0.4823529412, green: 0.3254901961, blue: 0.937254902, alpha: 1)
        sender.animateBorderColor(toColor: color, duration: 0.1)
    }
    
    @IBAction func onChangeSwitch(_ sender: Any) {
        isLightTheme = !self.themeSwitch.isOn
        
    }
}

extension UILabel {
    func changeColor(_ color: UIColor, duration: TimeInterval) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.textColor = color
        }, completion: nil)
    }
}

extension UIView {
    func animateBorderColor(toColor: UIColor, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toColor.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toColor.cgColor
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.3
        animation.values = [-10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ].map { $0 * 0.7 }
        layer.add(animation, forKey: "shake")
    }
}
