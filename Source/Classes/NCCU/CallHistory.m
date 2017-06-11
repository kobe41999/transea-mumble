//
//  CallHistory.m
//  Mumble
//
//  Created by HanChien Chun on 2016/8/24.
//
//

#import "CallHistory.h"
#import "CallHistoryObj.h"
#import <Parse/Parse.h>
#import "HistoryCellTableViewCell.h"

@interface CallHistory ()

@property NSMutableArray *hist;

@end

@implementation CallHistory

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hist=[[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    

    [self loadHistory];
    
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
    return _hist.count;
}

-(void) loadHistory
{
    PFQuery *query = [PFQuery queryWithClassName:@"CallHistory"];
    //[query addAscendingOrder:@"createdAt"];
    [query addDescendingOrder:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                NSString *expert=object[@"expert"];
                NSString *caller=object[@"caller"];
                NSNumber *score=object[@"score"];
                NSNumber *duration=object[@"duration"];
                
                NSLog(@"%@",expert);
                NSLog(@"%lf",[duration doubleValue]);
                
                CallHistoryObj *callHist=[[CallHistoryObj alloc] init];
                callHist.expert=expert;
                callHist.rating=score;
                callHist.duration=duration;
                callHist.date=[ object updatedAt];
                
                [_hist addObject:callHist];
                
            }
            [self.tableView reloadData];
            
        } else {
            NSLog(@"error..");
        }
    }];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"histCell" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[[HistoryCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"histCell"] autorelease];
        
    }
    
    CallHistoryObj *callObj=[_hist objectAtIndex:indexPath.row];
    cell.labelExpert.text=callObj.expert;
    cell.rating.value=[callObj.rating doubleValue];
    NSLog(@"duration=%d",(int)callObj.duration);
    cell.labelDuration.text=[self timeFormatted:(int) ([callObj.duration doubleValue])];
    
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //// here set format of date which is in your output date (means above str with format)
    
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];// here set format which you want...
    
    NSString *convertedString = [dateFormatter stringFromDate:callObj.date]; //here convert date in NSString
    NSLog(@"Converted String : %@",convertedString);
    cell.labelDate.text=convertedString;
    
    
    return cell;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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
