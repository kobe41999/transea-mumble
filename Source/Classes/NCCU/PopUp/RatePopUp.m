//
//  RatePopUp.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/24.
//
//

#import "RatePopUp.h"
#import <STPopup/STPopup.h>
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"
#import "HCSStarRatingView.h"

@interface RatePopUp ()

@property NSString *expert;
@property (retain, nonatomic) IBOutlet UILabel *labelExpertName;
@property (retain, nonatomic) IBOutlet HCSStarRatingView *rating;
@property AppDelegate *appDelegate;
@property int currentRating;

@end

@implementation RatePopUp

- (IBAction)onRate:(id)sender {
    PFObject *testObject = [PFObject objectWithClassName:@"CallHistory"];
    testObject[@"caller"] = _appDelegate.currentRequestUser;
    testObject[@"expert"] = _appDelegate.currentExpert;
    testObject[@"duration"] = [NSNumber numberWithDouble:_appDelegate.currentCallDuration];
    testObject[@"score"] = [NSNumber numberWithDouble:_currentRating];
    [testObject saveInBackground];
    
    
    [self.popupController dismiss];
}

- (IBAction)onRating:(id)sender {
    _currentRating=(int)_rating.value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Do any additional setup after loading the view.
    _labelExpertName.text=_appDelegate.currentExpert;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake(260, 190);
    self.landscapeContentSizeInPopup = CGSizeMake(260, 190);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_labelExpertName release];
    [_rating release];
    [super dealloc];
}
@end
