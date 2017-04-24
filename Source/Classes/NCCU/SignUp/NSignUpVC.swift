//
//  SignUpVC.swift
//  Mumble
//
//  Created by Wu Bryant on 2017/4/24.
//
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet var fieldUserName: UITextField!
    @IBOutlet var fieldUserPassword: UITextField!
    @IBOutlet var fieldMessage: UILabel!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var btnLogin: UIButton!

    
    
    override func viewDidLoad() {
        print("load complete")
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        btnSignUp.layer.borderWidth = 2.0
        btnSignUp.layer.borderColor = UIColor(colorLiteralRed: 214.0/225.0, green: 221.0/225.0, blue: 227.0/255.0, alpha: 1.0).cgColor
        
        btnLogin.layer.borderWidth = 2.0
        btnLogin.layer.borderColor = UIColor(colorLiteralRed: 214.0/255.0, green: 221.0/225.0, blue: 227.0/255.0, alpha: 1.0).cgColor
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onSignUp(_ sender: UIButton) {
        self.fieldMessage.text = ""
        if(self.IsValidEmail(checkString: self.fieldUserName.text!)){
            self.fieldMessage.text="Invalid Email Address"
        }
        
        let query = PFUser.query()
        query?.whereKey("username", equalTo: self.fieldUserName.text!)
        query?.getFirstObjectInBackground(block: { (object:PFObject?, error:Error?)-> Void in
                if(!(error != nil)){
                    if(object != nil){
                        self.fieldMessage.text="Please login with existing account"
                    }
                }
                else{
                    if(!self.IsValidEmail(checkString: self.fieldUserName.text!)){
                        self.fieldMessage.text = "Invalid Email Address"
                        return
                    }
                    
                    if(!self.checkPassword()){
                        self.fieldMessage.text="Please input password"
                        return
                    }
                    var user = PFUser()
                    user.username = self.fieldUserName.text
                    user.password = self.fieldUserPassword.text
                    user["GLOTTER"] = "GLOTTER"
                    user.signUpInBackground{
                        (success,error)->Void in
                        if(success){
                            self.fieldMessage.text="Sign Up Success"
                        }
                        if error != nil{
                            NSLog("Sign Up failed")
                        }
                        else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }
            
        })
    }
    @IBAction func onLogin(_ sender: UIButton) {
        if(!self.IsValidEmail(checkString: self.fieldUserName.text!)){
            self.fieldMessage.text="Invalid Email Address"
            return
        }
        if(!self.checkPassword()){
            self.fieldMessage.text="Please input password"
            return
        }
        PFUser.logInWithUsername(inBackground: self.fieldUserName.text!, password: self.fieldUserPassword.text!){
            (user: PFUser?, error: Error?) -> Void in
            if let error = error {
                if let errorString = (error as NSError).userInfo["error"] as? String {
                    NSLog(errorString);
                }
            } else {
                self.fieldMessage.text = "Log in success"
                self.navigationController?.popViewController(animated: true)
                // Hooray! Let them use the app now.
                NSLog("Logged in!");
            }
            
        }
    }
    
    func IsValidEmail(checkString:String) -> Bool {
        var stricterFilter:Bool = false
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailRegex = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: checkString)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func checkPassword() -> Bool {
        if(self.fieldUserPassword.text?.characters.count == 0 ){
            return false
        }
        return true
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
