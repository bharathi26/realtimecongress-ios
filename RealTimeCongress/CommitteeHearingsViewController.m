//
//  CommitteeHearingsViewController.m
//  RealTimeCongress
//
//  Created by Tom Tsai on 5/25/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "CommitteeHearingsViewController.h"
#import "JSONKit.h"
#import "SunlightLabsRequest.h"

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

@implementation CommitteeHearingsViewController

@synthesize parsedHearingData;
@synthesize jsonData;
@synthesize jsonKitDecoder;
@synthesize chamberControl;
@synthesize loadingIndicator;
@synthesize opQueue;
@synthesize hearingDays;
@synthesize committeeHearingsCell;
@synthesize hearingsTableView;
@synthesize sectionDataArray;
@synthesize hearingDayDictionary;

- (void)dealloc
{
    [super dealloc];
    [loadingIndicator release];
    [chamberControl release];
    [opQueue release];
    [parsedHearingData release];
    [hearingDays release];
    [hearingsTableView release];
    [sectionDataArray release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [parsedHearingData release];
    [hearingDays release];
    [sectionDataArray release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    hearingsTableView.delegate = self;
    hearingsTableView.dataSource = self;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self  action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //Make cells unselectable
    self.hearingsTableView.allowsSelection = NO;
    
    //Initialize the operation queue
    opQueue = [[NSOperationQueue alloc] init];
    
    // Refreshes table view data on segmented control press;
    [chamberControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
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
    if (parsedHearingData != NULL) {
        return [hearingDays count];
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
    // Create a custom cell for each entry. Set the height according to string length or autosize.
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CommitteeHearingsCell" owner:self options:nil];
        cell = committeeHearingsCell;
        self.committeeHearingsCell = nil;
    }
    //Calculate the correct size for each UILabel
    UILabel *committeeNameLabel;
    UILabel *timeAndPlaceLabel;
    UILabel *descriptionLabel;
    
    // Array that holds the hearings for the current day and section
    NSArray *sectionArray = [sectionDataArray objectAtIndex:indexPath.section];
    
    if (sectionArray != NULL) {
        //Position Committee Name text
        committeeNameLabel = (UILabel *)[cell viewWithTag:1];
        committeeNameLabel.text = [[[sectionArray objectAtIndex:indexPath.row] 
                                    objectForKey:@"committee"] objectForKey:@"name"];
        [committeeNameLabel sizeToFitFixedWidth:320];
    
        //Position Time and Place text
        timeAndPlaceLabel = (UILabel *)[cell viewWithTag:2];
        if (chamberControl.selectedSegmentIndex == 0) {
            timeAndPlaceLabel.text = [NSString stringWithFormat:@"%@", 
                                      [[sectionArray objectAtIndex:indexPath.row] 
                                        objectForKey:@"time_of_day"]];
        }
        else {
            timeAndPlaceLabel.text = [NSString stringWithFormat:@"%@ (%@) %@", 
                                      [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"time_of_day"], [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"room"],
                                      [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"legislative_day"]];
        }
        timeAndPlaceLabel.frame = CGRectMake(committeeNameLabel.frame.origin.x, 
                                             (committeeNameLabel.frame.origin.y + committeeNameLabel.frame.size.height),320, 0);
        [timeAndPlaceLabel sizeToFitFixedWidth:320];
        
        
        //Position Description text
        descriptionLabel = (UILabel *)[cell viewWithTag:3];
        descriptionLabel.text = [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"description"];
        descriptionLabel.frame = CGRectMake(committeeNameLabel.frame.origin.x, 
                                            (timeAndPlaceLabel.frame.origin.y + timeAndPlaceLabel.frame.size.height), 
                                            320, 0);
        [descriptionLabel sizeToFitFixedWidth:320];
        
    }
    
    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Sets the title of each section to the legislative day
    if (parsedHearingData != NULL) {
        return [hearingDays objectAtIndex:section];
    }
    else {
        return [NSString stringWithString:@" "];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Calculates the appropriate row height based on the size of the three text labels
    CGSize maxSize = CGSizeMake(320, CGFLOAT_MAX);
    NSArray *sectionArray = [sectionDataArray objectAtIndex:indexPath.section];
    
    CGSize committeeNameTextSize = [[[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"committee"] objectForKey:@"name"] sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:maxSize];
    
    CGSize timeAndPlaceTextSize;
    if (chamberControl.selectedSegmentIndex == 0) {
        timeAndPlaceTextSize = [[NSString stringWithFormat:@"%@", 
                                 [[sectionArray objectAtIndex:indexPath.row] 
                                  objectForKey:@"time_of_day"]] sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:maxSize];
    }
    else {
        timeAndPlaceTextSize = [[NSString stringWithFormat:@"%@ (%@)", 
                                 [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"time_of_day"], [[sectionArray objectAtIndex:indexPath.row] objectForKey:@"room"]] sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:maxSize];
    }
    
    CGSize descriptionTextSize = [[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"description"] sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:maxSize];
    
    return (committeeNameTextSize.height + timeAndPlaceTextSize.height + descriptionTextSize.height + 5);
}

#pragma mark - UI Actions
- (void) refresh
{
    //Set the navigation bar title to that of the selected chamber
    self.title = [NSString stringWithFormat:@"%@ Hearings", [chamberControl titleForSegmentAtIndex:chamberControl.selectedSegmentIndex]];
    
    //Disable scrolling while data is loading
    self.hearingsTableView.scrollEnabled = NO;
    
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
    jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
    NSArray *data = [items objectForKey:@"committee_hearings"];

    //Sort data by legislative day then split in to sections
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"legislative_day" ascending:YES];
    NSSortDescriptor *sortByTime = [NSSortDescriptor sortDescriptorWithKey:@"occurs_at" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *descriptors = [[NSArray alloc] initWithObjects: sortByDate, sortByTime,nil];
    parsedHearingData = [[NSArray alloc] initWithArray:[data sortedArrayUsingDescriptors:descriptors]];
    
    // A mutable array containing the unique hearing days
    hearingDays = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *hearing in parsedHearingData) {
        if (!([hearingDays containsObject:[hearing objectForKey:@"legislative_day"]])) {
            [hearingDays addObject:[hearing objectForKey:@"legislative_day"]];
        }
    }
    
    // Create the hearing day dictionary
    self.hearingDayDictionary = [NSMutableDictionary dictionary];
    
    // Create an array to store hearings for each legislative day
    for (NSString *aString in hearingDays) {
        //NSLog(@"Key for hearing day dictionary %@", aString);
        [hearingDayDictionary setObject:[NSMutableArray array] forKey:aString];
    }
    
    // Iterate through the hearings, adding each one to its respective array
    for (NSDictionary *hearing in parsedHearingData){
        NSString *anotherString = [hearing objectForKey:@"legislative_day"];
        [[hearingDayDictionary objectForKey:anotherString] addObject:hearing];
    }
    
    // Convert the hearing day dictionary into a mutable array
    NSMutableArray *hearingDayMutableArray = [[NSMutableArray alloc] init];
    for (NSString *string in hearingDays) {
        [hearingDayMutableArray addObject:[hearingDayDictionary objectForKey:string]];
    }
    
    sectionDataArray = [[NSArray alloc] initWithArray:hearingDayMutableArray];
}

- (void) retrieveData
{
    // Get the current date and format it for a url request
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    [dateFomatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todaysDate = [dateFomatter stringFromDate:[NSDate date]];
    
    // Generate request URL using Sunlight Labs Request class
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@", REQUEST_PAGE_SIZE], @"per_page",
                                       [[chamberControl titleForSegmentAtIndex:chamberControl.selectedSegmentIndex] lowercaseString], @"chamber",
                                       todaysDate, @"legislative_day__gte",
                                       nil];
    SunlightLabsRequest *dataRequest = [[SunlightLabsRequest alloc] initRequestWithParameterDictionary:requestParameters APICollection:CommitteeHearings APIMethod:nil];
    
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
        [self.hearingsTableView reloadData];
        
        //Hide the activity indicator once loading is complete
        [loadingIndicator stopAnimating];
        
        //Re-enable scrolling once loading is complete and the loading indicator disappears
        self.hearingsTableView.scrollEnabled = YES;
        
        // Reveal back button when loading is complete
        self.navigationItem.hidesBackButton = NO;
    }
}

@end
