//
//  CallHistory.swift
//  Mumble
//
//  Created by William on 2017/4/27.
//
//

import UIKit
import Parse


class CallHistory: UITableViewController {
    var hist = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hist = [Any]()
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
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
        return hist.count
    }
    
    func load() {
        let query = PFQuery(className: "CallHistory")
        //[query addAscendingOrder:@"createdAt"];
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: {(_ objects: [PFObject], _ error: Error?) -> Void in
            if error == nil {
                for object: PFObject in objects{
                    let expert: String = object["expert"] as! String
                    let caller:String=object["caller"] as! String
                    let score = object["score"]
                    let duration = object["duration"]
                    print("\(expert)")
                    print("(CDouble(duration))")
                    let callHist = CallHistoryObj()
                    callHist.expert = expert
                    callHist.rating = score as? NSNumber
                    callHist.duration = duration as? NSNumber
                    callHist.date = object.updatedAt
                    self.hist.append(callHist)
                }
                self.tableView.reloadData()
            }
            else {
                print("error..")
            }
        } as! ([PFObject]?, Error?) -> Void)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: HistoryCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "histCell", for: indexPath) as? HistoryCellTableViewCell
        if cell == nil {
            cell = HistoryCellTableViewCell(style: .default, reuseIdentifier: "histCell")
        }
        let callObj: CallHistoryObj? = (hist[indexPath.row] as? CallHistoryObj)
        cell?.labelExpert?.text = callObj?.expert
        cell?.rating?.value = CGFloat(CDouble((callObj?.rating)!))
        print("duration=\(Int((callObj?.duration)!))")
        cell?.labelDuration?.text = timeFormatted(Int(CDouble((callObj?.duration)!)))
        var dateFormatter = DateFormatter()
        // here we create NSDateFormatter object for change the Format of date..
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //// here set format of date which is in your output date (means above str with format)
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        // here set format which you want...
        let convertedString: String? = dateFormatter.string(from: (callObj?.date)!)
        //here convert date in NSString
        print("Converted String : \(String(describing: convertedString))")
        cell?.labelDate?.text = convertedString
        return cell!
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
