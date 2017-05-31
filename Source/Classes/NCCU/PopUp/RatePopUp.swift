//
//  RatePopUp.swift
//  Mumble
//
//  Created by Roger's Mac on 2017/4/24.
//
//
import UIKit
import STPopup
import FBSDKCoreKit
import ParseFacebookUtilsV4
import HCSStarRatingView

class RatePopUp: UIViewController {
    var expert: String = ""
    @IBOutlet var labelExpertName: UILabel!
    @IBOutlet var rating: HCSStarRatingView!
    var appDelegate: AppDelegate?
    var currentRating: Int = 0
    
    @IBAction func onRate(_ sender: Any) {
        let testObject = PFObject(className: "CallHistory")
        testObject["caller"] = appDelegate?.currentRequestUser
        testObject["expert"] = appDelegate?.currentExpert
        testObject["duration"] = Int((appDelegate?.currentCallDuration)!)
        testObject["score"] = Int(currentRating)
        testObject.saveInBackground()
        popupController?.dismiss()
    }
    
    @IBAction func onRating(_ sender: Any) {
        currentRating = Int(rating.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        // Do any additional setup after loading the view.
        labelExpertName.text = appDelegate?.currentExpert
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
