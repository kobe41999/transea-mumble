//
//  PopUpVC.swift
//  Mumble
//
//  Created by Roger's Mac on 2017/4/24.
//
//
import UIKit
import STPopup
import FBSDKCoreKit
import ParseFacebookUtilsV4
class PopUpVC: UIViewController {
    @IBOutlet var labelLanguage: UILabel!
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var fieldPricing: UITextField!
    @IBOutlet var imgIcon: UIImageView!
    var currentRequestUser: String = ""
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        let array: [Any]? = appDelegate?.currentRequestUser.replacingOccurrences(of: "info:", with: "User:").components(separatedBy: "@")
        labelUserName.text = array?[0] as! String
        currentRequestUser = (appDelegate?.currentRequestUser)!
    }
    
    func bid() {
        let serverURL: String = "http://162.243.49.105:8888/bid"
        let currentUser = PFUser.current()
        let userID: String = currentUser!.username!
        print("userid=\(userID)")
        if !(currentUser != nil) {
            return
        }
        var resultsDictionary: [AnyHashable: Any]
        // 返回的 JSON 数据
        let starter: String = currentRequestUser
        let bid = Int(CDouble(fieldPricing.text!)!)
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
        let post = String(data:jsonData!, encoding: String.Encoding.utf8)
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
                var responseText = String(data: data, encoding: String.Encoding.ascii)
                print("Response: \(responseText)")
                let newLineStr: String = "\n"
                responseText = responseText?.replacingOccurrences(of: "<br />", with: newLineStr)
            }
        } as! (URLResponse?, Data?, Error?) -> Void)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAccept(_ sender: Any) {
        bid()
        popupController?.dismiss()
    }
    
    @IBAction func btnDecline(_ sender: Any) {
        popupController?.dismiss()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentSizeInPopup = CGSize(width: CGFloat(260), height: CGFloat(190))
        landscapeContentSizeInPopup = CGSize(width: CGFloat(260), height: CGFloat(190))
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
