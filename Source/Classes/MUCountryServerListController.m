// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUCountryServerListController.h"

#import "MUDatabase.h"
#import "MUFavouriteServer.h"
#import "MUFavouriteServerListController.h"
#import "MUFavouriteServerEditViewController.h"
#import "MUServerRootViewController.h"
#import "MUConnectionController.h"
#import "MUServerCell.h"
#import "MUColor.h"
#import "MUOperatingSystem.h"

@interface MUCountryServerListController () <UIAlertViewDelegate, UISearchBarDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView    *_tableView;
    NSArray        *_visibleServers;
    NSArray        *_countryServers;
    NSString       *_countryName;
}
@end

@implementation MUCountryServerListController

- (id) initWithName:(NSString *)country serverList:(NSArray *)servers {
    self = [super init];
    if (self == nil)
        return nil;
    
    _countryServers = [servers retain];
    _visibleServers = [servers mutableCopy];
    _countryName = [[country copy] retain];
    
    return self;
}

- (void) dealloc {
    [_countryName release];
    [_countryServers release];
    [_visibleServers release];
    
    [super dealloc];
}

- (UITableView *) tableView {
    return _tableView;
}

- (void) viewDidLoad {    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    [self resetSearch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.titleView = nil;
    self.navigationItem.title = _countryName;
    self.navigationItem.hidesBackButton = NO;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        navBar.tintColor = [UIColor whiteColor];
        navBar.translucent = NO;
        navBar.backgroundColor = [UIColor blackColor];
    }
    navBar.barStyle = UIBarStyleBlackOpaque;

    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsZero;
    }

    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    [searchButton release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_visibleServers count];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *serverItem = [_visibleServers objectAtIndex:[indexPath row]];
    if ([[serverItem objectForKey:@"ca"] integerValue] > 0) {
        cell.backgroundColor = [MUColor verifiedCertificateChainColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUServerCell *cell = (MUServerCell *) [tableView dequeueReusableCellWithIdentifier:[MUServerCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[[MUServerCell alloc] init] autorelease];
    }
    
    NSDictionary *serverItem = [_visibleServers objectAtIndex:[indexPath row]];
    [cell populateFromDisplayName:[serverItem objectForKey:@"name"]
                         hostName:[serverItem objectForKey:@"ip"]
                             port:[serverItem objectForKey:@"port"]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    return (UITableViewCell *) cell;
}

#pragma mark -
#pragma mark Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *serverItem = [_visibleServers objectAtIndex:[indexPath row]];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[serverItem objectForKey:@"name"]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Add as favourite", nil),
                                                                NSLocalizedString(@"Connect", nil), nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [sheet showInView:[self tableView]];
    [sheet release];
}

- (void) actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    NSDictionary *serverItem = [_visibleServers objectAtIndex:[indexPath row]];

    // Connect
    if (index == 1) {
        NSString *title = NSLocalizedString(@"Username", nil);
        NSString *msg = NSLocalizedString(@"Please enter the username you wish to use on this server", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Connect", nil), nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setText:[MUDatabase usernameForServerWithHostname:[serverItem objectForKey:@"ip"] port:[[serverItem objectForKey:@"port"] intValue]]];
        [alert show];
        [alert release];

    // Add as favourite
    } else if (index == 0) {
        [self presentAddAsFavouriteDialogForServer:serverItem];
    // Cancel
    } else if (index == 2) {
        [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void) presentAddAsFavouriteDialogForServer:(NSDictionary *)serverItem {
    MUFavouriteServer *favServ = [[MUFavouriteServer alloc] init];
    [favServ setDisplayName:[serverItem objectForKey:@"name"]];
    [favServ setHostName:[serverItem objectForKey:@"ip"]];
    [favServ setPort:[[serverItem objectForKey:@"port"] intValue]];
    [favServ setUserName:[MUDatabase usernameForServerWithHostname:[serverItem objectForKey:@"ip"] port:[[serverItem objectForKey:@"port"] intValue]]];

    UINavigationController *modalNav = [[UINavigationController alloc] init];
    MUFavouriteServerEditViewController *editView = [[MUFavouriteServerEditViewController alloc] initInEditMode:NO withContentOfFavouriteServer:favServ];

    [editView setTarget:self];
    [editView setDoneAction:@selector(doneButtonClicked:)];
    [modalNav pushViewController:editView animated:NO];
    [editView release];

    [[self navigationController] presentModalViewController:modalNav animated:YES];

    [modalNav release];
    [favServ release];
}

- (void) doneButtonClicked:(id)sender {
    MUFavouriteServerEditViewController *editView = (MUFavouriteServerEditViewController *)sender;
    MUFavouriteServer *favServ = [editView copyFavouriteFromContent];
    [MUDatabase storeFavourite:favServ];
    [favServ release];

    MUFavouriteServerListController *favController = [[MUFavouriteServerListController alloc] init];
    UINavigationController *navCtrl = [self navigationController];
    [navCtrl popToRootViewControllerAnimated:NO];
    [navCtrl pushViewController:favController animated:YES];
    [favController release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    NSDictionary *serverItem = [_visibleServers objectAtIndex:[indexPath row]];
    
    if (buttonIndex == 1) {
        MUConnectionController *connCtrlr = [MUConnectionController sharedController];
        [connCtrlr connetToHostname:[serverItem objectForKey:@"ip"]
                               port:[[serverItem objectForKey:@"port"] intValue]
                       withUsername:[[alertView textFieldAtIndex:0] text]
                        andPassword:nil
           withParentViewController:self];
    }

    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark SearchBar methods

- (void) resetSearch {
    [_visibleServers release];
    _visibleServers = [_countryServers retain];
}

- (void) performSearchForTerm:(NSString *)searchTerm {        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[_countryServers count]];
        for (NSDictionary *serverItem in _countryServers) {
            if ([(NSString *)[serverItem objectForKey:@"name"] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound ||
                    [(NSString *)[serverItem objectForKey:@"ip"] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [results addObject:serverItem];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_visibleServers release];
            _visibleServers = results;
            [self.tableView reloadData]; 
        });
    });
}

#pragma mark -
#pragma mark Search Bar Delegate Methods

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    [self performSearchForTerm:searchText];
    [searchBar resignFirstResponder];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0){
        [self resetSearch];
        [self.tableView reloadData];
        return;
    }
    [self performSearchForTerm:searchText];
}

#pragma mark -
#pragma mark UIKeyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *val = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval t;
    [val getValue:&t];
    
    val = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve c;
    [val getValue:&c];
    
    val = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect r;
    [val getValue:&r];
    r = [self.view convertRect:r fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:t];
    [UIView setAnimationCurve:c];
    _tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, r.size.height, 0.0f);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *val = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval t;
    [val getValue:&t];
    
    val = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve c;
    [val getValue:&c];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:t];
    [UIView setAnimationCurve:c];
    _tableView.contentInset = UIEdgeInsetsZero;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Actions

- (void) searchButtonClicked:(id)sender {
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *cancelSearchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSearchButtonClicked:)];
    self.navigationItem.rightBarButtonItem = cancelSearchButton;
    [cancelSearchButton release];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleBlack;
    [searchBar sizeToFit];
    self.navigationItem.titleView = searchBar;
    [searchBar release];

    [searchBar becomeFirstResponder];
}

- (void) cancelSearchButtonClicked:(id)sender {
    [self resetSearch];
    [self.tableView reloadData];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    [searchButton release];
    
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.titleView = nil;
    [self.navigationItem setTitle:_countryName];
}

@end

