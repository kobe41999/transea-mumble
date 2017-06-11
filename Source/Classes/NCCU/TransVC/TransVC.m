//
//  TransVC.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/14.
//
//

#import "TransVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"
#import "SBJson4.h"


NSString *serverURL=@"http://162.243.49.105:8888/query";

@interface TransVC ()

@end

@implementation TransVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
    
}





- (IBAction)onBtnTrans:(id)sender {
    NSLog(@"ready to post");
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *userID=currentUser.username;
    NSLog(@"userid=%@",userID);
    if(!currentUser){
        
        
    }
    
    
    NSMutableDictionary *resultsDictionary;// 返回的 JSON 数据
    NSDictionary *userData=[[NSDictionary alloc] initWithObjectsAndKeys:userID,@"userid",@"Vietnamese",@"req_lang",nil];
    NSDictionary *mainJson = [[NSDictionary alloc] initWithObjectsAndKeys:userData, @"data",@"query",@"type",nil];
  
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
