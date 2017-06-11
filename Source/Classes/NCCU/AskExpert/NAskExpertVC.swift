//
//  AskExpertVC.swift
//  Mumble
//
//  Created by 賴昱榮 on 2017/4/24.
//
//

import Foundation
import UIKit
class AskExpertVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let serverURL: String = "http://162.243.49.105:8888/query"
        print("on search")
        print("ready to post")
        let currentUser = PFUser.current()
        let userID: String = currentUser!.username!
        print("userid=\(userID)")
        if !(currentUser != nil) {
            
        }
        var resultsDictionary: [AnyHashable: Any]
        // 返回的 JSON 数据
        let userData: [AnyHashable: Any] = [
            "userid" : userID,
            "req_lang" : "Vietnamese"
        ]
        
        let mainJson: [AnyHashable: Any] = [
            "data" : userData,
            "type" : "query"
        ]
        
        var error: Error?
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: mainJson, options: JSONSerialization.WritingOptions.prettyPrinted)
        let post = String(data: jsonData!, encoding: String.Encoding.utf8)
        print("\(String(describing: post))")
        //NSString *queryString = [NSString stringWithFormat:@"http://example.com/username.php?name=%@", [self.txtName text]];
        let theRequest = NSMutableURLRequest(url: URL(string: serverURL)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        theRequest.httpMethod = "POST"
        theRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // should check for and handle errors here but we aren't
        theRequest.httpBody = jsonData
        NSURLConnection.sendAsynchronousRequest(theRequest as URLRequest, queue: OperationQueue.main, completionHandler: {(_ response: URLResponse, _ data: Data, _ error: Error?) -> Void in
            if error != nil {
                //do something with error
                print("\(String(describing: error?.localizedDescription))")
            }
            else {
                var responseText = String(describing:(data, encoding: String.Encoding.ascii))
                print("Response: \(responseText)")
                let newLineStr: String = "\n"
                responseText = responseText.replacingOccurrences(of: "<br />", with: newLineStr)
            }
        } as! (URLResponse?, Data?, Error?) -> Void)
    }
}
import FBSDKCoreKit
import ParseFacebookUtilsV4
