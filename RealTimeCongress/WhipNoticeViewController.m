#import "WhipNoticeViewController.h"
#import "SunlightLabsRequest.h"
#import "WhipNoticesWebViewController.h"
#import "JSONKit.h"
#import "GANTracker.h"
#import "Reachability.h"

@implementation WhipNoticeViewController

@synthesize parsedWhipNoticeData;
@synthesize loadingIndicator;
@synthesize noticeDaysDictionary;
@synthesize sectionDataArray;
@synthesize noticeDaysArray;
@synthesize reachabilityInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [loadingIndicator release];
    [parsedWhipNoticeData release];
    [reachabilityInfo release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    // Release all cached URL responses if memory warning is received
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set Title
    self.title = @"Whip Notices";
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Check if URL Cache memory size is set to zero. Reset to 10 MB if it is.
    if([[NSURLCache sharedURLCache] memoryCapacity] == 0){
        [[NSURLCache sharedURLCache] setMemoryCapacity:10485760];
    }
    
    //Create a reachability object to monitor internet reachability
    reachabilityInfo = [[Reachability reachabilityForInternetConnection] retain];
    [reachabilityInfo startNotifier];
    
    //Retrieve data
    [self retrieveData];
    NSError *error;
    
    //Register a page view to the Google Analytics tracker
    if (![[GANTracker sharedTracker] trackPageview:@"/whipnotices"
                                         withError:&error]) {
        // Handle error here
    }
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
    // Return the number of sections.
    if (parsedWhipNoticeData != NULL) {
        return [noticeDaysArray count];
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [sectionDataArray objectAtIndex:section];
    return [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *sectionArray = [sectionDataArray objectAtIndex:indexPath.section];
    
    if (sectionArray != NULL) {
        // Configure the cell...
        NSString *partyType;
        NSString *noticeType;
        if ([[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"party"] isEqual:@"D"]) {
            partyType = @"Democratic";
        }
        else {
            partyType = @"Republican";
        }
        
        noticeType = [[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"notice_type"] capitalizedString];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ Whip", partyType, noticeType];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Sets the title of each section to the legislative day
    
    static NSDateFormatter *dateFormatter;
    
    if (parsedWhipNoticeData != NULL) {
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *rawDate = [dateFormatter dateFromString: [noticeDaysArray objectAtIndex:section]];
        [dateFormatter setDateFormat:@"EEEE, MMMM dd"];
        return [dateFormatter stringFromDate:rawDate];
    }
    else {
        return [NSString stringWithString:@" "];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
     WhipNoticesWebViewController *webViewController = [[WhipNoticesWebViewController alloc] initWithNibName:@"WhipNoticesWebViewController" bundle:nil];
    webViewController.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[parsedWhipNoticeData objectAtIndex:indexPath.row] objectForKey:@"url"]]];
     [self.navigationController pushViewController:webViewController animated:YES];
     [WhipNoticesWebViewController release];
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
        [self.loadingIndicator startAnimating];
        
        NSError *error;
        //Register a page view to the Google Analytics tracker
        if (![[GANTracker sharedTracker] trackPageview:@"/whipnotices"
                                             withError:&error]) {
            // Handle error here
        }
        
        // Generate request URL using Sunlight Labs Request class
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                           @"for_date", @"order",
                                           @"desc", @"sort",
                                           nil];
        SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
        connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
        [connection sendRequest];
        NSLog(@"User initiated refresh. Use network.");
    }
    else {
        NSLog(@"The internet is inaccessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Internet inaccessible."
                                                         message:@"Internet inaccessible."
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
    
    //Assign received data
    NSDictionary *items = [notification userInfo];
    NSArray *data = [items objectForKey:@"documents"];
    
    //Sort data by legislative day then split in to sections
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"for_date" ascending:NO];
    NSSortDescriptor *sortByTime = [NSSortDescriptor sortDescriptorWithKey:@"posted_at" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *descriptors = [[NSArray alloc] initWithObjects: sortByDate, sortByTime, nil];
    parsedWhipNoticeData = [[NSArray alloc] initWithArray:[data sortedArrayUsingDescriptors:descriptors]];
    
    // A mutable array containing the unique notice days
    noticeDaysArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *notice in parsedWhipNoticeData) {
        if (!([noticeDaysArray containsObject:[notice objectForKey:@"for_date"]])) {
            [noticeDaysArray addObject:[notice objectForKey:@"for_date"]];
        }
    }
    
    // Create the notice day dictionary
    self.noticeDaysDictionary = [NSMutableDictionary dictionary];
    
    // Create an array to store notices for each notice day
    for (NSString *aString in noticeDaysArray) {
        [noticeDaysDictionary setObject:[NSMutableArray array] forKey:aString];
    }
    
    // Iterate through the notices, adding each one to its respective array
    for (NSDictionary *notice in parsedWhipNoticeData){
        NSString *anotherString = [notice objectForKey:@"for_date"];
        [[noticeDaysDictionary objectForKey:anotherString] addObject:notice];
    }
    
    // Convert the notice day dictionary into a mutable array
    NSMutableArray *noticeDayMutableArray = [[NSMutableArray alloc] init];
    for (NSString *string in noticeDaysArray) {
        [noticeDayMutableArray addObject:[noticeDaysDictionary objectForKey:string]];
    }
    
    sectionDataArray = [[NSArray alloc] initWithArray:noticeDayMutableArray];
    
    //Reload the table once data retrieval is complete
    [self.tableView reloadData];
    
    //Hide the activity indicator and network activity indicator once loading is complete
    [loadingIndicator stopAnimating];
    
    //Re-enable scrolling once loading is complete and the loading indicator disappears
    self.tableView.scrollEnabled = YES;
    
    // Reveal back button when loading is complete
    self.navigationItem.hidesBackButton = NO;
}

- (void) parseCachedData:(NSData *)data {
    NSDictionary *decodedData = [[JSONDecoder decoder] objectWithData:data];
    NSArray *dataArray = [decodedData objectForKey:@"documents"];
    
    //Sort data by legislative day then split in to sections
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"for_date" ascending:NO];
    NSSortDescriptor *sortByTime = [NSSortDescriptor sortDescriptorWithKey:@"posted_at" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *descriptors = [[NSArray alloc] initWithObjects: sortByDate, sortByTime, nil];
    parsedWhipNoticeData = [[NSArray alloc] initWithArray:[dataArray sortedArrayUsingDescriptors:descriptors]];
    
    // A mutable array containing the unique notice days
    noticeDaysArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *notice in parsedWhipNoticeData) {
        if (!([noticeDaysArray containsObject:[notice objectForKey:@"for_date"]])) {
            [noticeDaysArray addObject:[notice objectForKey:@"for_date"]];
        }
    }
    
    // Create the notice day dictionary
    self.noticeDaysDictionary = [NSMutableDictionary dictionary];
    
    // Create an array to store notices for each notice day
    for (NSString *aString in noticeDaysArray) {
        [noticeDaysDictionary setObject:[NSMutableArray array] forKey:aString];
    }
    
    // Iterate through the notices, adding each one to its respective array
    for (NSDictionary *notice in parsedWhipNoticeData){
        NSString *anotherString = [notice objectForKey:@"for_date"];
        [[noticeDaysDictionary objectForKey:anotherString] addObject:notice];
    }
    
    // Convert the notice day dictionary into a mutable array
    NSMutableArray *noticeDayMutableArray = [[NSMutableArray alloc] init];
    for (NSString *string in noticeDaysArray) {
        [noticeDayMutableArray addObject:[noticeDaysDictionary objectForKey:string]];
    }
    
    sectionDataArray = [[NSArray alloc] initWithArray:noticeDayMutableArray];
    
    //Reload the table once data retrieval is complete
    [self.tableView reloadData];
    
    //Hide the activity indicator and network activity indicator once loading is complete
    [loadingIndicator stopAnimating];
    
    //Re-enable scrolling once loading is complete and the loading indicator disappears
    self.tableView.scrollEnabled = YES;
    
    // Reveal back button when loading is complete
    self.navigationItem.hidesBackButton = NO;
    
}

- (void) retrieveData
{
    // Check network reachability. If unreachable, display alert view. Otherwise, retrieve data
    NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        // Generate request URL using Sunlight Labs Request class
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                           @"for_date", @"order",
                                           @"desc", @"sort",
                                           nil];
        SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
        
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[dataRequest request]];
        NSDate *responseAge = [[cachedResponse userInfo] objectForKey:@"CreationDate"];
        NSDate *currentDate = [NSDate date];
        
        // Check if there is an unexpired cached response
        if ((cachedResponse != nil) && ([currentDate timeIntervalSinceDate:responseAge] < 300)) {
            [self parseCachedData:[[[NSURLCache sharedURLCache] cachedResponseForRequest:[dataRequest request]] data]];
            NSLog(@"Cached data loaded");
        }
        else{
            connection = [[SunlightLabsConnection alloc] initWithSunlightLabsRequest:dataRequest];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseData:) name:SunglightLabsRequestFinishedNotification object:connection];
            [connection sendRequest];
            NSLog(@"No cached data. Use network.");
        }
    }
    else {
        NSLog(@"The internet is inaccessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Internet inaccessible."
                                                         message:@"Internet inaccessible."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"  
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void) reachabilityChanged {
    NetworkStatus internetStatus = [reachabilityInfo currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        NSLog(@"The internet is inaccessible.");
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Internet inaccessible."
                                                         message:@"Internet inaccessible."
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
