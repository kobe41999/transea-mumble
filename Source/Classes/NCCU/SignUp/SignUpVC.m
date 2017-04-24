//
//  SignUpVC.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/14.
//
//

#import "SignUpVC.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"


@interface SignUpVC ()

@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;

@property (retain, nonatomic) IBOutlet UITextField *fieldUserName;

@property (retain, nonatomic) IBOutlet UITextField *fieldUserPassword;
@property (retain, nonatomic) IBOutlet UILabel *fieldMessage;


@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [_fieldUserName setDelegate:self];
    [_fieldUserPassword setDelegate:self];
    
    [[_btnSignUp layer] setBorderWidth:2.0f];
    [[_btnSignUp layer] setBorderColor:[UIColor colorWithRed:214.0f/255.0f
                                                       green:221.0f/255.0f
                                                        blue:227.0f/255.0f
                                                       alpha:1.0f].CGColor];
    
    [[_btnLogin layer] setBorderWidth:2.0f];
    [[_btnLogin layer] setBorderColor:[UIColor colorWithRed:214.0f/255.0f
                                                       green:221.0f/255.0f
                                                        blue:227.0f/255.0f
                                                       alpha:1.0f].CGColor];
    NSLog(@"");
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLogin:(id)sender {
    if(![self NSStringIsValidEmail:[_fieldUserName text]]){
        [_fieldMessage setText:@"Invalid Email Address"];
        return;
    }
    
    if(![self checkPassword]){
        [_fieldMessage setText:@"Please input password"];
        return;
    }
    
    [PFUser logInWithUsernameInBackground:[_fieldUserName text]password:[_fieldUserPassword text]
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [_fieldMessage setText:@"Log in success"];
                                            [self.navigationController popViewControllerAnimated:YES];
                                        } else {
                                            // The login failed. Check error to see why.
                                             NSString *errorString = [error userInfo][@"error"];
                                            [_fieldMessage setText:errorString];
                                        }
                                    }];
    
}
- (IBAction)onSignUp:(id)sender {
    [_fieldMessage setText:@""];
    if(![self NSStringIsValidEmail:[_fieldUserName text]]){
        [_fieldMessage setText:@"Invalid Email Address"];
        return;
    }
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[_fieldUserName text]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            if(object){
                DLog(@"exist");
                [_fieldMessage setText:@"Please login with existing account"];
            }else{
                DLog(@"can sign up");
            }
        }else{
            // can sign up
            if(![self NSStringIsValidEmail:[_fieldUserName text]]){
                [_fieldMessage setText:@"Invalid Email Address"];
                return;
            }
            
            if(![self checkPassword]){
                [_fieldMessage setText:@"Please input password"];
                return;
            }
            
            PFUser *user = [PFUser user];
            user.username = [_fieldUserName text];
            user.password = [_fieldUserPassword text];
            user[@"GLOTTER"]=@"GLOTTER";
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                     [_fieldMessage setText:@"Sign up success!"];
                }
                if (!error) {   // Hooray! Let them use the app now.
                    
                    DLog(@"Sign up success");
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                    DLog(@"%@",errorString);
                }
            }];
        }
    }];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(BOOL) checkPassword
{
    if([[_fieldUserPassword text] length]==0){
        return NO;
    }
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
    [_fieldUserName release];
    [_fieldUserPassword release];
    [_fieldMessage release];
    [_btnSignUp release];
    [_btnLogin release];
    [super dealloc];
}
@end
