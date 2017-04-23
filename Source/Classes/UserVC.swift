//
//  UserVC.swift
//  Mumble
//
//  Created by 賴昱榮 on 2017/4/24.
//
//

import Foundation
import UIKit
class UserVC: UIViewController {
    @IBOutlet var imgHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var switchAvailable: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let currentUser = PFUser.current()
        let userID: String = currentUser!.username!
        print("userid=\(userID)")
        if (currentUser != nil) {
            let array: [Any] = userID.components(separatedBy: "@")
            labelName.text = array[0] as! String
        }
    }
    
    @IBAction func testBid(_ sender: Any) {
        let serverURL: String = "http://162.243.49.105:8888/bid"
        let currentUser = PFUser.current()
        let userID: String = currentUser!.username!
        print("userid=\(userID)")
        if !(currentUser != nil) {
            return
        }
        var resultsDictionary: [AnyHashable: Any]
        // 返回的 JSON 数据
        let starter: String = "starter"
        let bid = Int(20)
        let userData: [AnyHashable: Any] = [
            "userid" : userID,
            "starter" : starter,
            "bid" : bid
        ]
        
        let mainJson: [AnyHashable: Any] = [
            "data" : userData,
            "type" : "bid"
        ]
        
        var error: Error?
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: mainJson, options: JSONSerialization.WritingOptions.prettyPrinted)
        let post = String(data: jsonData!, encoding: String.Encoding.utf8)
        print("\(post)")
        //NSString *queryString = [NSString stringWithFormat:@"http://example.com/username.php?name=%@", [self.txtName text]];
        var theRequest = NSMutableURLRequest(url: URL(string: serverURL)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        theRequest.httpMethod = "POST"
        theRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // should check for and handle errors here but we aren't
        theRequest.httpBody = jsonData
        NSURLConnection.sendAsynchronousRequest(theRequest as URLRequest, queue: OperationQueue.main, completionHandler: {(_ response: URLResponse, _ data: Data, _ error: Error?) -> Void in
            if error != nil {
                //do something with error
                print("\(error?.localizedDescription)")
            }
            else {
                var responseText = String(describing:(data, encoding: String.Encoding.ascii))
                print("Response: \(responseText)")
                let newLineStr: String = "\n"
                responseText = responseText.replacingOccurrences(of: "<br />", with: newLineStr)
            }
        } as! (URLResponse?, Data?, Error?) -> Void)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        let currentUser = PFUser.current()
        if switchAvailable.isOn {
            print("ON")
            currentUser?["AVAILABLE"] = Int(true)
        }
        else {
            print("OFF")
            currentUser?["AVAILABLE"] = Int(false)
        }
        currentUser?.saveInBackground(block: {(_ succeeded: Bool, _ error: Error?) -> Void in
        })
    }
    
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    deinit {
    }
}
import ParseFacebookUtilsV4
