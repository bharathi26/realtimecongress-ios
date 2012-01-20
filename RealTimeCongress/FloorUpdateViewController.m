//
//  FloorUpdateViewController.m
//  RealTimeCongress
//
//  Created by Stephen Searles on 6/4/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "FloorUpdateViewController.h"
#import "FloorUpdate.h"
#import "SunlightLabsRequest.h"
#import "GANTracker.h"
#import "JSONKit.h"
#import "Reachability.h"

@interface UILabel (sizingExtensions)
- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth;
@end

@implementation UILabel (sizingExtensions)


- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@interface NSString (CancelRequest)

- (void)cancelRequest;

@end

@implementation NSString (CancelRequest)

- (void)cancelRequest {
    
}

@end

@implementation FloorUpdateViewController

@synthesize control;
@synthesize floorUpdatesTableView;

- (void)dealloc
{
    [control release];
    [floorUpdates release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)receiveFloorUpdate:(NSNotification *)notification {
    [connection release];
    connection = nil;
    NSDictionary * userInfo = [notification userInfo];
    
    static NSDateFormatter * dateFormatter;
    static NSDateFormatter *updateDayFormatter;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    if (updateDayFormatter == nil) {
        updateDayFormatter = [[NSDateFormatter alloc] init];
    }
    [updateDayFormatter setDateFormat:@"EEEE, MMMM dd"];
    NSMutableString * floorUpdateText = [NSMutableString stringWithCapacity:100];
    
    for (id update in [userInfo objectForKey:@"floor_updates"]) {
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"timestamp"]];
        for (id str in [update objectForKey:@"events"]) {
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [floorUpdateText appendFormat:@"%@",str];
        }
        FloorUpdate * floorUpdate = [[[FloorUpdate alloc] initWithDisplayText:floorUpdateText atDate:date withCellWidth:cellWidth] autorelease];
        
        // Check if the date has been added to update days array. Add it if it hasn't.
        NSString *updateDay = [updateDayFormatter stringFromDate:[floorUpdate date]];
        if (![updateDays containsObject: updateDay]) {
            [updateDays addObject:updateDay];
        }

        // Check if there is an array for the update day. If there isn't, create an array to store updates for that day. 
        if ([updateDayDictionary objectForKey:updateDay] == nil) {
            [updateDayDictionary setObject:[NSMutableArray array] forKey:updateDay];
            // Add the update to its respective array
            [[updateDayDictionary objectForKey:updateDay] addObject:floorUpdate];
        }
        else {
            // Add the update to its respective array if it already exists
            [[updateDayDictionary objectForKey:updateDay] addObject:floorUpdate];
        }
        
        [floorUpdateText setString:@""];
    }
    
    id last = [[floorUpdates lastObject] retain];
    [floorUpdates removeObject:[floorUpdates lastObject]];
    [floorUpdates removeAllObjects];
    
    for (NSString *updateDayString in updateDays) {
        [floorUpdates addObject:[updateDayDictionary objectForKey:updateDayString]];
    }
    
    [floorUpdates addObject:last];
    [last release];
    [self.floorUpdatesTableView reloadData];
}

- (void) parseCachedData:(NSData *)data {
    NSDictionary *userInfo = [[JSONDecoder decoder] objectWithData:data];
    
    static NSDateFormatter * dateFormatter;
    static NSDateFormatter *updateDayFormatter;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    if (updateDayFormatter == nil) {
        updateDayFormatter = [[NSDateFormatter alloc] init];
    }
    [updateDayFormatter setDateFormat:@"EEEE, MMMM dd"];
    NSMutableString * floorUpdateText = [NSMutableString stringWithCapacity:100];
    
    for (id update in [userInfo objectForKey:@"floor_updates"]) {
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"timestamp"]];
        for (id str in [update objectForKey:@"events"]) {
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [floorUpdateText appendFormat:@"%@",str];
        }
        FloorUpdate * floorUpdate = [[[FloorUpdate alloc] initWithDisplayText:floorUpdateText atDate:date withCellWidth:cellWidth] autorelease];
        
        // Check if the date has been added to update days array. Add it if it hasn't.
        NSString *updateDay = [updateDayFormatter stringFromDate:[floorUpdate date]];
        if (![updateDays containsObject: updateDay]) {
            [updateDays addObject:updateDay];
        }
        
        // Check if there is an array for the update day. If there isn't, create an array to store updates for that day. 
        if ([updateDayDictionary objectForKey:updateDay] == nil) {
            [updateDayDictionary setObject:[NSMutableArray array] forKey:updateDay];
            // Add the update to its respective array
            [[updateDayDictionary objectForKey:updateDay] addObject:floorUpdate];
        }
        else {
            // Add the update to its respective array if it already exists
            [[updateDayDictionary objectForKey:updateDay] addObject:floorUpdate];
        }
        
        [floorUpdateText setString:@""];
    }
    
    id last = [[floorUpdates lastObject] retain];
    [floorUpdates removeObject:[floorUpdates lastObject]];
    [floorUpdates removeAllObjects];
    
    for (NSString *updateDayString in updateDays) {
        [floorUpdates addObject:[updateDayDictionary objectForKey:updateDayString]];
    }
    
    [floorUpdates addObject:last];
    [last release];
    [self.floorUpdatesTableView reloadData];
}

- (void)refresh {
    
    // Check if URL Cache memory size is set to zero. Reset to 10 MB if it is.
    if([[NSURLCache sharedURLCache] memoryCapacity] == 0){
        [[NSURLCache sharedURLCache] setMemoryCapacity:10485760];
    }
    
    //Track page view based on selected chamber control button
    NSError *error;
    if (control.selectedSegmentIndex == 0) {
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/floor-updates/house"
                                             withError:&error]) {
            // Handle error here
        }
    }
    
    else {
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/floor-updates/senate"
                                             withError:&error]) {
            // Handle error here
        }
    }
    page = 0;
    if (connection) {
        [connection cancel];
        [connection release];
    }
    
    for (id obj in floorUpdates) {
        if (obj != @"LoadingRow") {
            [obj makeObjectsPerformSelector:@selector(cancelRequest)];
        }
    }
    
    // Sets the appropriate header title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Updates", [control titleForSegmentAtIndex:control.selectedSegmentIndex]];
    
    [floorUpdates removeAllObjects];
    [updateDays removeAllObjects];
    [floorUpdates addObject:@"LoadingRow"];
    
    // set refresh flag
    refreshed = YES;
    
    [self.floorUpdatesTableView reloadData];
}

- (void)switchChambers {
    [self refresh];
    [updateDayDictionary removeAllObjects];

    refreshed = NO;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Register for reachability changed notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachabilityInfo stopNotifier];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    //Determine which cell width to use based on UI idiom of current device and current orientation
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //If the device is in a landscape orientation, use a cell width for a split view detail pane
        if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
            (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            cellWidth = DETAIL_CELL_WIDTH;
        }
        //Otherwise the device is in portrait orientation. Use an appropriate cell width.
        else {
            cellWidth = PORTRAIT_CELL_WIDTH;
        }
    }
    else {
        cellWidth= IPHONE_CELL_WIDTH;
    }
    
    //Set title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Updates", [control titleForSegmentAtIndex:control.selectedSegmentIndex]];
    
    //Set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    [control addTarget:self action:@selector(switchChambers) forControlEvents:UIControlEventValueChanged];
    page = 0;
    self.floorUpdatesTableView.allowsSelection = NO;
    if (!floorUpdates) {
        floorUpdates = [[NSMutableArray alloc] initWithCapacity:20];
        [floorUpdates addObject:@"LoadingRow"];
    }
    
    //Array to keep track of the unique days for each update
    if (!updateDays){
        updateDays = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    // Create a dictionary to associate updates with days
    updateDayDictionary = [[NSMutableDictionary dictionary] retain];
    
    [super viewWillAppear:animated];
    
    //Create a reachability object to monitor internet reachability
    reachabilityInfo = [[Reachability reachabilityForInternetConnection] retain];
    [reachabilityInfo startNotifier];
    
    //Track page view based on selected chamber control button
    NSError *error;
    if (control.selectedSegmentIndex == 0) {
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/floor-updates/house"
                                             withError:&error]) {
            // Handle error here
        }
    }
    
    else {
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/floor-updates/senate"
                                             withError:&error]) {
            // Handle error here
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [floorUpdates removeAllObjects];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    //iPad supports all orientations
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        //iPhone supports only portrait orientation
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
        (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        cellWidth = PORTRAIT_CELL_WIDTH;
    }
    else{
        cellWidth = DETAIL_CELL_WIDTH;
    }
    
    //Redraw table view cells
    [self.floorUpdatesTableView reloadRowsAtIndexPaths:[self.floorUpdatesTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([updateDays count] > 0) {
        return ([updateDays count]+1);
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([[floorUpdates objectAtIndex:section] isEqual:@"LoadingRow"]) {
        return 1;
    }
    else{
        NSArray *sectionArray = [floorUpdates objectAtIndex:section];
        return [sectionArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[floorUpdates objectAtIndex:indexPath.section] isEqual:@"LoadingRow"]) {
        return 44.0;
    }
    else{
        NSArray *sectionArray = [floorUpdates objectAtIndex:indexPath.section];
        return [[sectionArray objectAtIndex:indexPath.row] textHeight] + 60;
        //55 = the height of the table cell wihtout the event text (76 - 21)
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [floorUpdates indexOfObject:[floorUpdates lastObject]]) {
        page += 1;
        NSString *chamber = [control selectedSegmentIndex] == 0 ? [NSString stringWithString:@"house"] : [NSString stringWithString:@"senate"];
        NSDictionary *requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ul",page],@"page",chamber,@"chamber", nil];
        SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:FloorUpdates APIMethod:nil];

        // Check network reachability. If unreachable, display alert view. Otherwise, retrieve data
        NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
        
        // If refreshed flag is set to yes, load data from network source.
        if (refreshed) {
            if (internetStatus != NotReachable) {
                connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFloorUpdate:) name:SunglightLabsRequestFinishedNotification object:connection];
                [connection sendRequest];
                refreshed = NO;
            }
            else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"The internet is currently inaccessible."
                                                                 message:@"Please check your connection and try again."
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"  
                                                       otherButtonTitles:nil];
                
                [alert show];
                [alert release];
            }
        }
        else {
            NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[dataRequest request]];
            NSDate *responseAge = [[cachedResponse userInfo] objectForKey:@"CreationDate"];
            NSDate *currentDate = [NSDate date];
            
            // Check if there is an unexpired cached response
            if ((cachedResponse != nil) && ([currentDate timeIntervalSinceDate:responseAge] < 300)) {
                [self parseCachedData:[cachedResponse data]];
            }
            else {
                if (internetStatus != NotReachable) {
                    connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFloorUpdate:) name:SunglightLabsRequestFinishedNotification object:connection];
                    [connection sendRequest];
                    refreshed = NO;
                }
                else {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"The internet is currently inaccessible."
                                                                     message:@"Please check your connection and try again."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"  
                                                           otherButtonTitles:nil];
                    
                    [alert show];
                    [alert release];
                }
            }
        }
        
        [dataRequest release];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[floorUpdates objectAtIndex:indexPath.section] isEqual:@"LoadingRow"]) {
        static NSString *CellIdentifier = @"LoadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LoadingTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        return cell;
    }
    
    else if ([[[floorUpdates objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isMemberOfClass:[FloorUpdate class]]) {
        NSArray *sectionArray = [floorUpdates objectAtIndex:indexPath.section];
        static NSString *CellIdentifier = @"FloorUpdateCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FloorUpdateTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        UILabel * eventText = (UILabel *)[cell viewWithTag:2];
        [(UILabel *)[cell viewWithTag:1] setText:[[sectionArray objectAtIndex:indexPath.row] displayDate]];
        [eventText setText:[[sectionArray objectAtIndex:indexPath.row] displayText]];
        [eventText sizeToFitFixedWidth:cellWidth];
        return cell;
    }  
    
    else {
        static NSString * cellIdentifier = @"Cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Sets the title of each section to the legislative day
    if ([updateDays count] > 0) {
        if (section == [updateDays count]) {
            return nil;
        }
        else {
            return [updateDays objectAtIndex:section];
        }
        
    }
    else {
        return [NSString stringWithString:@"No events logged"];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Add the popover button to the left navigation item.
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Remove the popover button.
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:nil animated:NO];
}

@end
