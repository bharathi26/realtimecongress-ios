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

#pragma mark Utility extensions

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

    //Set title
    self.title = @"CBO Estimates";
    
    //Set up refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self  action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //An activity indicator to indicate loading
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingIndicator setCenter:self.view.center];
    [self.view addSubview:loadingIndicator];
    
    //Register for reachability changed notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachabilityInfo stopNotifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Check if URL Cache memory size is set to zero. Reset to 10 MB if it is.
    if([[NSURLCache sharedURLCache] memoryCapacity] == 0){
        [[NSURLCache sharedURLCache] setMemoryCapacity:10485760];
    }
    
    //Array to keep track of the unique days for each update
    if (!reportDaysArray){
        reportDaysArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    // Create a dictionary to associate updates with days
    reportDaysDictionary = [[NSMutableDictionary dictionary] retain];
    
    //Create a reachability object to monitor internet reachability
    reachabilityInfo = [[Reachability reachabilityForInternetConnection] retain];
    [reachabilityInfo startNotifier];
    
    //Retrieve data
    [self retrieveData];
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
    
    //iPad supports all orientations
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        //iPhone supports only portrait orientation
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([reportDaysArray count] > 0) {
        return ([reportDaysArray count] + 1);
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else {
        NSArray *sectionArray = [sectionDataArray objectAtIndex:section - 1];
        return [sectionArray count];   
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // Set informative text in the top most cell
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [cell.textLabel sizeToFitFixedWidth:CELL_WIDTH];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = @"The Congressional Budget Office is required to develop a cost estimate for virtually every bill reported by Congressional committees to show how it would affect spending or revenues over the next five years or more.";
        return cell;
    }
    
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        NSArray *sectionArray = [sectionDataArray objectAtIndex:(indexPath.section - 1)];
        
        if (sectionArray != NULL) {
            // Configure the cell...
            [cell.textLabel sizeToFitFixedWidth:CELL_WIDTH];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
            cell.textLabel.text = [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        }
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Sets the title of each section to the legislative day
    if ([reportDaysArray count] > 0) {
        if ((section == [reportDaysArray count]) || (section == 0)) {
            return nil;
        }
        else {
            return [reportDaysArray objectAtIndex:section - 1];
        }
        
    }
    else {
        return [NSString stringWithString:@"No events logged"];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    WhipNoticesWebViewController *webViewController = [[WhipNoticesWebViewController alloc] initWithNibName:@"WhipNoticesWebViewController" bundle:nil];
    NSArray *sectionArray = [sectionDataArray objectAtIndex:(indexPath.section - 1)];
    NSURL * url = [NSURL URLWithString:[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"url"]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
    webViewController.urlRequest = urlRequest;
    webViewController.launchType = @"cbo_estimates";
    [self.navigationController pushViewController:webViewController animated:YES];
    [WhipNoticesWebViewController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90;
    }
    else {
        //Calculates the appropriate row height based on the size of the three text labels
        CGSize maxSize = CGSizeMake(CELL_WIDTH, CGFLOAT_MAX);
        NSArray *sectionArray = [sectionDataArray objectAtIndex:(indexPath.section - 1)];
        
        CGSize titleTextSize = [[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:maxSize];
        
        return (titleTextSize.height + 60);
    }
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
        if (![[GANTracker sharedTracker] trackPageview:@"/cbo_estimates"
                                             withError:&error]) {
            // Handle error here
        }
        
        // Generate request URL using Sunlight Labs Request class
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                           @"cbo_estimate", @"document_type",
                                           nil];
        SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
        connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
        [connection sendRequest];
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
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"posted_at"]];
        
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
        NSDate * date = [dateFormatter dateFromString:[update objectForKey:@"posted_at"]];
        
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
    if (![[GANTracker sharedTracker] trackPageview:@"/cbo_estimates"
                                         withError:&error]) {
        // Handle error here
    }
    
    // Generate request URL using Sunlight Labs Request class
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                       @"cbo_estimate", @"document_type",
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
    }
    else{
        // Check network reachability. If unreachable, display alert view. Otherwise, retrieve data
        NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
            [connection sendRequest];
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

- (void) reachabilityChanged {
    NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"The internet is currently inaccessible."
                                                         message:@"Please check your connection and try again."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"  
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
    }
    else {
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
