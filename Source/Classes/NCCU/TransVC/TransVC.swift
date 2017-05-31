//
//  TransVC.swift
//  Mumble
//
//  Created by Wu Bryant on 2017/4/23.
//
//

import UIKit

class TransVC: UIViewController {
    let serverURL = "http://162.243.49.105:8888/query"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OnBtnTrans(_ sender: UIButton) {
        NSLog("ready to post")
        
        if let currentUser = PFUser.current(){
            let userID = currentUser.username
            NSLog(userID!)
            
            let userData:Dictionary = ["userid":userID,"req_lang":"Vietnamese"]
            let mainJson:Dictionary = ["data":userData,"type":"query"] as [String : Any]
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: mainJson, options:.prettyPrinted)
                let post = String(data: jsonData, encoding: String.Encoding.utf8)
                NSLog(post!)
                let theRequest = NSMutableURLRequest(url:URL(string:serverURL)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                theRequest.httpMethod="POST"
                theRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                theRequest.httpBody = jsonData
                NSURLConnection.sendAsynchronousRequest(theRequest as URLRequest, queue: OperationQueue.main, completionHandler:
                    {(_ response:URLResponse?,_ data:Data?, _ error:Error?) -> Void in
                    if error != nil{
                            NSLog((error?.localizedDescription)!)
                    }
                    else{
                        var responseText = String(data: data!, encoding: String.Encoding.ascii)
                        print("responseText: \(responseText!)")
                        let newLineStr: String = "\n"
                        responseText = responseText!.replacingOccurrences(of: "<br />", with: newLineStr)
                    }
                    
                })
                
                
            }
            catch{
                NSLog("json parse error")
            }
            
            
            
            
        }
        
        
        
        
        
        
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
