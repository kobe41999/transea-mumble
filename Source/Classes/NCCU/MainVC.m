//
//  MainVC.m
//  Mumble
//
//  Created by HanChien Chun on 2016/7/26.
//
//

#import "MainVC.h"
#import "MUConnectionController.h"
#import <RMQClient/RMQClient.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"
#import "MHTabBarSegue.h"
#import <STPopup/STPopup.h>
#import "AppDelegate.h"
#import "RatePopUp.h"


NSString *const TransVCChangedNotification = @"TransVCChangedNotification";
NSString *const TransVCAlreadyVisibleNotification = @"TransVCViewControllerAlreadyVisibleNotification";


@interface MainVC ()

@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (nonatomic, strong) NSMutableDictionary *viewControllersByIdentifier;
@property (strong, nonatomic) NSString *destinationIdentifier;

@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (retain, nonatomic) IBOutlet UIView *container;

@property AppDelegate *appDelegate;

@property CFTimeInterval startTime;
@property NSString *currentExpert;
@property NSString *currentRequester;

@property (retain, nonatomic) IBOutlet UILabel *currentUserLabel;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _started=false;
    [self.navigationController.navigationBar setHidden:NO];
    
    [self subScribe];
    
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // ...
    //[self _loginWithFacebook];
    [self _loadData];
    
    self.viewControllersByIdentifier = [NSMutableDictionary dictionary];
    PFUser *currentUser = [PFUser currentUser];
    
    if(!currentUser){
       [_btnSignUp sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else{
        NSLog(@"%@",currentUser.username);
        //_currentUserLabel.text=currentUser.username;
        NSArray *array = [currentUser.username componentsSeparatedByString:@"@"];
        [_currentUserLabel setText:[array objectAtIndex:0]];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEnded:) name:@"onCallEnded" object:nil];
    
}

-(void) onCallEnded:(NSNotification *)noti
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - _startTime;
    NSLog(@"call interval=%lf",elapsedTime);
    NSLog(@"with expert: %@",_currentExpert);
    NSLog(@"with caller: %@",_currentRequester);
    _appDelegate.currentRequestUser=_currentRequester;
    _appDelegate.currentExpert=_currentExpert;
    _appDelegate.currentCallDuration=elapsedTime;
    
    PFUser *currentUser = [PFUser currentUser];
    
    if(![currentUser.username containsString:_currentExpert]){
        // upload score...
        
        STPopupController *showRequest = [[STPopupController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:@"NCCU-Glotter" bundle:nil] instantiateViewControllerWithIdentifier:@"ratePopUp"]];
        [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:74/255.0 green:77/255.0 blue:80/255.0 alpha:1.0];
        [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
        [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
        
        showRequest.containerView.layer.cornerRadius = 4;
        /* [topScaleSetting.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];*/
        
        [showRequest presentInViewController:self];
        
    }
    
}

- (IBAction)loginFB:(id)sender {
    [self _loginWithFacebook];
}

- (IBAction)parseLogin:(id)sender {
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![PFUser currentUser] || // Check if user is cached
        ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        
        // need to login
        /*PFLogInViewController *controller = [[PFLogInViewController alloc] init];
        logInController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsFacebook
                                  | PFLogInFieldsDismissButton);
        [self presentViewController:controller animated:YES];*/
        
        
    }
    NSLog(@"chile=%ld",self.childViewControllers.count);
    if (self.childViewControllers.count ==0) {
        [self performSegueWithIdentifier:@"Trans" sender:[self.buttons objectAtIndex:0]];
    }
    
    // debug
    
    //[self connectServer];
}



- (void)_loadData {
    // ...
    // ...
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSLog(@" id=%@",facebookID);
            
            // Now add the data to the UI elements
            // ...
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"password" equalTo:facebookID];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (object){
                    
                }else{
                    PFUser *user = [PFUser user];
                    user.username = name;
                    user.password = facebookID;
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {   // Hooray! Let them use the app now.
                        } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                        }
                    }];
                }
            }];
            
          
            
        }else{
            DLog(@"error %@",[error localizedDescription]);
            
        }
    }];
}

- (void)_loginWithFacebook {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self _loadData];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self _loadData];
        }
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) connectServer
{
    _startTime=CACurrentMediaTime();
    
    PFUser *currentUser = [PFUser currentUser];
    MUConnectionController *connCtrlr = [MUConnectionController sharedController];
    // TODO: make it constant
    
    
    [connCtrlr connetToHostname:@"162.243.49.105"
                           port:64738
                   withUsername:currentUser.username
                    andPassword:@""
       withParentViewController:self];
}
- (IBAction)onConnect:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        //Your code goes in here
        NSLog(@"Main Thread Code");
        if(!_started){
         [self connectServer];
            _started=true;
        }
    }];
   
}

-(void) subScribe
{
     RMQConnection *conn = [[RMQConnection alloc] initWithUri:@"amqp://jordan:aaaaaa@162.243.49.105:5672/ttsai" delegate:[RMQConnectionDelegateLogger new]];
    [conn start];
    
    id<RMQChannel> ch = [conn createChannel];
    RMQExchange *x = [ch fanout:@"logs"];
    RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive];
    
    [q bind:x];
    
    NSLog(@"Waiting for logs.");
    
    [q subscribe:^(RMQMessage * _Nonnull message) {
        NSLog(@"Received %@", [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
        
        NSString *msg=[[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
        
        PFUser *currentUser = [PFUser currentUser];
        
        _appDelegate.currentRequestUser=msg;
        if([msg containsString:@"decision"]){
            NSLog(@"decision:%@",msg);
            NSArray *array = [msg componentsSeparatedByString:@"#"];
            NSString *user=[array objectAtIndex:1];
            NSString *expert=[array objectAtIndex:2];
            NSLog(@"decision");
            _currentExpert=[[NSString alloc] initWithString:expert];
            _currentRequester=[[NSString alloc] initWithString:user];
            NSLog(@"current request user %@",_currentRequester);
            
            if([currentUser.username containsString:user] || [currentUser.username containsString:expert]){
                [self connectServer];
            }
            
        }else if([msg containsString:@"bid"]){
            NSArray *array = [msg componentsSeparatedByString:@"#"];
            NSString *bidder=[array objectAtIndex:1];
            
            NSString *starter=[array objectAtIndex:2];
            NSNumber *price=[NSNumber numberWithDouble:[[array objectAtIndex:3] doubleValue]];
            
            NSLog(@"bidder=%@",bidder);
            
            NSDictionary *dict = @{@"bidder" :
                                       bidder,@"starter":starter,@"price":price
                                   };
            
            if(![bidder containsString:currentUser.username] && [starter containsString:currentUser.username]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bid" object:nil userInfo:dict];
            }
            
        }else if (![msg containsString:currentUser.username]) {
            
            
            
            
            STPopupController *showRequest = [[STPopupController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:@"NCCU-Glotter" bundle:nil] instantiateViewControllerWithIdentifier:@"requertPopUp"]];
            [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:74/255.0 green:77/255.0 blue:80/255.0 alpha:1.0];
            [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
            [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
            
            showRequest.containerView.layer.cornerRadius = 4;
            /* [topScaleSetting.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];*/
            
            [showRequest presentInViewController:self];
        
        }
        //[self connectServer];
    }];
    
}



- (IBAction)onTestRabbit:(id)sender {
    RMQConnection *conn = [[RMQConnection alloc] initWithUri:@"amqp://southwind:aaaaaa@162.243.49.105:5672/ttsai" delegate:[RMQConnectionDelegateLogger new]];
    
    [conn start];
    
    id<RMQChannel> ch = [conn createChannel];
    RMQExchange *x = [ch fanout:@"logs"];
    
    NSString *msg = @"Hello World ihone!!";
    
    [x publish:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [x publish:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [x publish:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Sent %@", msg);
    
    [conn close];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Trans"]) {
    }
    else if ([segue.identifier isEqualToString:@"User"]) {
    }
    
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    
    self.oldViewController = self.destinationViewController;
    
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    /*if (![self.viewControllersByIdentifier objectForKey:segue.identifier]) {
     [self.viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
     }*/
    
    [self.viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    
    [self.buttons setValue:@NO forKeyPath:@"selected"];
    
    self.selectedIndex = [self.buttons indexOfObject:sender];
    
    
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [self.viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TransVCChangedNotification object:nil];
    
}


- (void)dealloc {
    [_container release];
    [_btnSignUp release];
    [_currentUserLabel release];
    [super dealloc];
}
@end
