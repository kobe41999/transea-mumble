//
//  TransTableVC.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/15.
//
//

#import "TransTableVC.h"
#import "Translator.h"
#import "TransCell.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "DebugKit.h"
#import "PFQuery.h"


@interface TransTableVC ()

@property NSMutableArray *translators;
@end

@implementation TransTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _translators=[[NSMutableArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBid:)
                                                 name:@"bid"
                                               object:nil];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
}

-(void) onBid:(NSNotification *) notification
{
    NSDictionary *dict = [notification userInfo];
    
    
   /* NSDictionary *dict = @{@"bidder" :
                               bidder,@"starter":starter,@"price":price
                           };
    */
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL if_append=true;
    
    
    
    NSString *bidder=[dict objectForKey:@"bidder"];
    NSString *starter=[dict objectForKey:@"starter"];
    NSNumber *price=[dict objectForKey:@"price"];
    NSLog(@"%@",bidder);
    NSLog(@"%lf",[price doubleValue]);
    
    for(int i=0;i!=_translators.count;i++){
        Translator *translator=[_translators objectAtIndex:i];
        if([bidder containsString:translator.userName]){
            if_append=false;
            return;
        }
    }
    
    
    Translator *translator=[[Translator alloc] init];
    NSArray *array = [bidder componentsSeparatedByString:@"@"];
    translator.userName=[array objectAtIndex:0];
    translator.price=price;
    NSLog(@"%@",translator.userName);
    
    [_translators addObject:translator];
     
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



- (void)viewWillAppear:(BOOL)animated {
    Translator *translator=[[Translator alloc] init];
    //[_translators addObject:translator];
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"data count=%ld",_translators.count);
    
    return [_translators count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    Translator *translator=[_translators objectAtIndex:indexPath.row];
    // start session...
    [self decide:translator.userName withPrice:translator.price];
}

-(void) decide:(NSString *)expertID withPrice:(NSNumber *)price
{
    
    NSString *serverURL=@"http://162.243.49.105:8888/decision";
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *userID=currentUser.username;
    NSLog(@"userid=%@",userID);
    if(!currentUser){
    }
    
    NSMutableDictionary *resultsDictionary;// 返回的 JSON 数据
    NSDictionary *userData=[[NSDictionary alloc] initWithObjectsAndKeys:userID,@"userid",@"Vietnamese",@"req_lang",expertID,@"expertid",price,@"price", nil];
    NSDictionary *mainJson = [[NSDictionary alloc] initWithObjectsAndKeys:userData, @"data",@"decision",@"type",nil];
    
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransCell *cell = (TransCell *)[tableView dequeueReusableCellWithIdentifier:@"TransCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[[TransCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TransCell"] autorelease];
        
    }
    
    //cell.labelUserName.text=@"test";
    
    Translator *translator=[_translators objectAtIndex:indexPath.row];
    if(translator){
        NSLog(@"%@",translator.userName);
        cell.labelUserName.text=translator.userName;
        cell.price.text=[NSString stringWithFormat:@"%.1f",[translator.price doubleValue]];
    }
    //NSLog(@"%@",translator.userName);
    //cell.labelUserName.text=translator.userName;
    //cell.price.text=[NSString stringWithFormat:@"%.1f",translator.price];
   // NSLog(@"cell ok");
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
