#import "WhipNoticeViewController.h"
#import "SunlightLabsRequest.h"
#import "WhipNoticesWebViewController.h"
#import "JSONKit.h"

@implementation WhipNoticeViewController

@synthesize parsedWhipNoticeData;
@synthesize jsonData;
@synthesize jsonKitDecoder;
@synthesize loadingIndicator;
@synthesize opQueue;
@synthesize noticeDaysDictionary;
@synthesize sectionDataArray;
@synthesize noticeDaysArray;

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
    [opQueue release];
    [parsedWhipNoticeData release];
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
    //Set Title
    self.title = @"Whip Notices";
    
    //Set up refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self  action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //Initialize the operation queue
    opQueue = [[NSOperationQueue alloc] init];
    
    //An activity indicator to indicate loading
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingIndicator setCenter:self.view.center];
    [self.view addSubview:loadingIndicator];
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
    //Refresh data
    [self refresh];
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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *noticeDate = [dateFormatter dateFromString: [[sectionArray objectAtIndex:indexPath.row] 
                                                             objectForKey:@"for_date"]];
        [dateFormatter setDateFormat:@"EEEE, MMMM d"];
        NSString *formattedDate = [dateFormatter stringFromDate:noticeDate];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ Whip", partyType, noticeType];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", formattedDate];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Sets the title of each section to the legislative day
    if (parsedWhipNoticeData != NULL) {
        return [noticeDaysArray objectAtIndex:section];
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
    //Disable scrolling while data is loading
    self.tableView.scrollEnabled = NO;
    
    //Animate the activity indicator when loading data
    [self.loadingIndicator startAnimating];
    
    // Hide back button while loading
    self.navigationItem.hidesBackButton = YES;
    
    //Asynchronously retrieve data
    NSInvocationOperation* dataRetrievalOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                                   selector:@selector(retrieveData) object:nil] autorelease];
    [dataRetrievalOp addObserver:self forKeyPath:@"isFinished" options:0 context:NULL];
    [opQueue addOperation:dataRetrievalOp];
}

- (void) parseData
{
    //JSONKit decoding
    jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
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
}

- (void) retrieveData
{
    // Generate request URL using Sunlight Labs Request class
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                       @"for_date", @"sort",
                                       @"desc", @"order",
                                       nil];
    SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:Documents APIMethod:nil];
    
    //JSONKit requests
    
    jsonData = [NSData dataWithContentsOfURL:[dataRequest.request URL]];
    
    if (jsonData != NULL) {
        [self parseData];
    }
}

#pragma mark Key-Value Observing methods
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"isFinished"]) {
        //Reload the table once data retrieval is complete
        [self.tableView reloadData];
        
        //Hide the activity indicator once loading is complete
        [loadingIndicator stopAnimating];
        
        //Re-enable scrolling once loading is complete and the loading indicator disappears
        self.tableView.scrollEnabled = YES;
        
        // Reveal back button when loading is complete
        self.navigationItem.hidesBackButton = NO;
    }
}

@end
