//
//  TransTableVC.swift
//  Mumble
//
//  Created by William on 2017/4/27.
//
//


import ParseFacebookUtilsV4
import UIKit


class TransTableVC: UITableViewController{
    var translators = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translators = [Any]()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onBid), name: NSNotification.Name(rawValue: "bid"), object: nil)
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        UITableViewCell.appearance().backgroundColor = UIColor.clear
    }
    
    func onBid(_ notification: Notification) {
        let dict: [AnyHashable: Any]? = notification.userInfo
        /* NSDictionary *dict = @{@"bidder" :
         bidder,@"starter":starter,@"price":price
         };
         */
        _ = PFUser.current()
        var if_append: Bool = true
        let bidder: String? = (dict?["bidder"] as? String)
        let _: String? = (dict?["starter"] as? String)
        let price = (dict?["price"] as? NSNumber)
        print("\(String(describing: bidder))")
        print("\(CDouble(price!))")
        var i = 0
        while i != translators.count {
            let translator: Translator? = (translators[i] as? Translator)
            if (bidder?.contains((translator?.userName)!))! {
                if_append = false
                return
            }
            i += 1
        }
        let translator = Translator()
        let array: [Any]? = bidder?.components(separatedBy: "@")
        translator.userName = array?[0] as! String
        translator.price = price
        print("\(translator.userName)")
        translators.append(translator)
        DispatchQueue.main.sync(execute: {() -> Void in
            tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = Translator()
        //[_translators addObject:translator];
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("data count=\(translators.count)")
        return translators.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        let translator: Translator? = (translators[indexPath.row] as? Translator)
        // start session...
        decide((translator?.userName)!, withPrice: (translator?.price)!)
    }
    
    func decide(_ expertID: String, withPrice price: NSNumber) {
        let serverURL: String = "http://162.243.49.105:8888/decision"
        let currentUser = PFUser.current()
        let userID: String = currentUser!.username!
        print("userid=\(userID)")
        if !(currentUser != nil) {
            
        }
        var _: [AnyHashable: Any]
        // 返回的 JSON 数据
        let userData: [AnyHashable: Any] = [
            "userid" : userID,
            "req_lang" : "Vietnamese",
            "expertid" : expertID,
            "price" : price
        ]
        
        let mainJson: [AnyHashable: Any] = [
            "data" : userData,
            "type" : "decision"
        ]
        
        var _: Error?
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TransCell? = (tableView.dequeueReusableCell(withIdentifier: "TransCell", for: indexPath) as? TransCell)
        if cell == nil {
            cell = TransCell(style: .default, reuseIdentifier: "TransCell")
        }
        //cell.labelUserName.text=@"test";
        let translator: Translator? = (translators[indexPath.row] as? Translator)
        if translator != nil {
            print("\(String(describing: translator?.userName))")
            cell?.labelUserName?.text = translator?.userName
            cell?.price?.text = String(format: "%.1f", CDouble((translator?.price)!))
        }
        //NSLog(@"%@",translator.userName);
        //cell.labelUserName.text=translator.userName;
        //cell.price.text=[NSString stringWithFormat:@"%.1f",translator.price];
        // NSLog(@"cell ok");
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
}
