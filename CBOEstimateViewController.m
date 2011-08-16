//
//  CBOEstimateViewController.m
//  RealTimeCongress
//
//  Created by Tom Tsai on 8/16/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "CBOEstimateViewController.h"
#import "WhipNoticesWebViewController.h"
#import "SunlightLabsRequest.h"
#import "JSONKit.h"
#import "GANTracker.h"
#import "Reachability.h"

@implementation CBOEstimateViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UI Actions

- (void) refresh
{
    // Check network reachability. If unreachable, display alert view. Otherwise, retrieve data
    NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //Disable scrolling while data is loading
        self.tableView.scrollEnabled = NO;
        
        //Animate the activity indicator and network activity indicator when loading data
        [loadingIndicator startAnimating];
        
        NSError *error;
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/crs_reports"
                                             withError:&error]) {
            // Handle error here
        }
        
        // Generate request URL using Sunlight Labs Request class
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                           @"crs_report", @"document_type",
                                           nil];
        SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
        connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
        [connection sendRequest];
        NSLog(@"User initiated refresh. Use network.");
    }
    else {
        NSLog(@"The internet is inaccessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"The internet is currently inaccessible."
                                                         message:@"Please check your connection and try again."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"  
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void) parseData: (NSNotification *)notification
{
    //Release connection upon data receiption
    [connection release];
    connection = nil;
    
    // Clear array when new data received
    [reportDaysArray removeAllObjects];
    
    //Assign received data
    NSDictionary *items = [notification userInfo];
    
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
    
    for (id update in [items objectForKey:@"documents"]) {
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"released_at"]];
        
        // Check if the date has been added to update days array. Add it if it hasn't.
        NSString *updateDay = [updateDayFormatter stringFromDate: date];
        if (![reportDaysArray containsObject: updateDay]) {
            [reportDaysArray addObject:updateDay];
        }
        
        // Check if there is an array for the update day. If there isn't, create an array to store updates for that day. 
        if ([reportDaysDictionary objectForKey:updateDay] == nil) {
            [reportDaysDictionary setObject:[NSMutableArray array] forKey:updateDay];
            // Add the update to its respective array
            [[reportDaysDictionary objectForKey:updateDay] addObject:update];
        }
        else {
            // Add the update to its respective array if it already exists
            [[reportDaysDictionary objectForKey:updateDay] addObject:update];
        }
    }
    
    sectionDataArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSString *updateDayString in reportDaysArray) {
        if (updateDayString != @"") {
            [sectionDataArray addObject:[reportDaysDictionary objectForKey:updateDayString]];
        }
    }
    
    //Reload the table once data retrieval is complete
    [self.tableView reloadData];
    
    //Hide the activity indicator and network activity indicator once loading is complete
    [loadingIndicator stopAnimating];
    
    //Re-enable scrolling once loading is complete and the loading indicator disappears
    self.tableView.scrollEnabled = YES;
}

- (void) parseCachedData:(NSData *)data {
    NSDictionary *items = [[JSONDecoder decoder] objectWithData:data];
    
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
    
    for (id update in [items objectForKey:@"documents"]) {
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"released_at"]];
        
        // Check if the date has been added to update days array. Add it if it hasn't.
        NSString *updateDay = [updateDayFormatter stringFromDate: date];
        if (![reportDaysArray containsObject: updateDay]) {
            [reportDaysArray addObject:updateDay];
        }
        
        // Check if there is an array for the update day. If there isn't, create an array to store updates for that day. 
        if ([reportDaysDictionary objectForKey:updateDay] == nil) {
            [reportDaysDictionary setObject:[NSMutableArray array] forKey:updateDay];
            // Add the update to its respective array
            [[reportDaysDictionary objectForKey:updateDay] addObject:update];
        }
        else {
            // Add the update to its respective array if it already exists
            [[reportDaysDictionary objectForKey:updateDay] addObject:update];
        }
    }
    
    sectionDataArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSString *updateDayString in reportDaysArray) {
        [sectionDataArray addObject:[reportDaysDictionary objectForKey:updateDayString]];
    }
    
    //Reload the table once data retrieval is complete
    [self.tableView reloadData];
    
    //Hide the activity indicator and network activity indicator once loading is complete
    [loadingIndicator stopAnimating];
    
    //Re-enable scrolling once loading is complete and the loading indicator disappears
    self.tableView.scrollEnabled = YES;
}

- (void) retrieveData
{
    NSError *error;
    //Register a page view to the Google Analytics tracker
    if (![[GANTracker sharedTracker] trackPageview:@"/crs_reports"
                                         withError:&error]) {
        // Handle error here
    }
    
    // Generate request URL using Sunlight Labs Request class
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                       @"crs_report", @"document_type",
                                       nil];
    SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[dataRequest request]];
    NSDate *responseAge = [[cachedResponse userInfo] objectForKey:@"CreationDate"];
    NSDate *currentDate = [NSDate date];
    
    //Animate the activity indicator and network activity indicator when loading data
    [loadingIndicator startAnimating];
    
    // Check if there is an unexpired cached response
    if ((cachedResponse != nil) && ([currentDate timeIntervalSinceDate:responseAge] < 300)) {
        [self parseCachedData:[[[NSURLCache sharedURLCache] cachedResponseForRequest:[dataRequest request]] data]];
        NSLog(@"Cached data loaded");
    }
    else{
        // Check network reachability. If unreachable, display alert view. Otherwise, retrieve data
        NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
            [connection sendRequest];
            NSLog(@"No cached data. Use network.");
        }
        else {
            NSLog(@"The internet is inaccessible.");
            
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

- (void) reachabilityChanged {
    NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        NSLog(@"The internet is inaccessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"The internet is currently inaccessible."
                                                         message:@"Please check your connection and try again."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"  
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
    }
    else {
        NSLog(@"The internet is now accessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Internet now accessible."
                                                         message:@"Internet now accessible."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"  
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

@end
