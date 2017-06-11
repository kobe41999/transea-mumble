//
//  PopUpVC.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/15.
//
//

#import "PopUpVC.h"
#import <STPopup/STPopup.h>
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"

@interface PopUpVC ()
@property (retain, nonatomic) IBOutlet UILabel *labelLanguage;
@property (retain, nonatomic) IBOutlet UILabel *labelUserName;
@property (retain, nonatomic) IBOutlet UITextField *fieldPricing;
@property (retain, nonatomic) IBOutlet UIImageView *imgIcon;
@property NSString *currentRequestUser;
@property AppDelegate *appDelegate;

@end

@implementation PopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *array = [[_appDelegate.currentRequestUser stringByReplacingOccurrencesOfString:@"info:" withString:@"User:"] componentsSeparatedByString:@"@"];
    [_labelUserName setText:[array objectAtIndex:0]];
    
    _currentRequestUser=_appDelegate.currentRequestUser;
 
}

-(void) bid
{
    NSString *serverURL=@"http://162.243.49.105:8888/bid";
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *userID=currentUser.username;
    NSLog(@"userid=%@",userID);
    if(!currentUser){
        
        return;
    }
    
    
    NSMutableDictionary *resultsDictionary;// 返回的 JSON 数据
    
    NSString *starter=_currentRequestUser;
    NSNumber *bid=[NSNumber numberWithDouble:[_fieldPricing.text doubleValue]];
    
    
    
    NSDictionary *userData=[[NSDictionary alloc] initWithObjectsAndKeys:userID,@"userid",starter,@"starter",bid,@"bid",nil];
    NSDictionary *mainJson = [[NSDictionary alloc] initWithObjectsAndKeys:userData, @"data",@"bid",@"type",nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mainJson
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSString *post =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",post);
    
    //NSString *queryString = [NSString stringWithFormat:@"http://example.com/username.php?name=%@", [self.txtName text]];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:
                                                     serverURL]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // should check for and handle errors here but we aren't
    [theRequest setHTTPBody:jsonData];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            //do something with error
            NSLog(@"%@",[error localizedDescription]);
        } else {
            NSString *responseText = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding];
            NSLog(@"Response: %@", responseText);
            
            NSString *newLineStr = @"\n";
            responseText = [responseText stringByReplacingOccurrencesOfString:@"<br />" withString:newLineStr];
            
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAccept:(id)sender {
    [self bid];
    [self.popupController dismiss];
}

- (IBAction)btnDecline:(id)sender {
    [self.popupController dismiss];
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
    [_labelLanguage release];
    [_labelUserName release];
    [_fieldPricing release];
    [_imgIcon release];
    [super dealloc];
}
@end
