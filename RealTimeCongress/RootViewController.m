#import "RootViewController.h"
#import "AboutViewController.h"
#import "CommitteeHearingsViewController.h"
#import "WhipNoticeViewController.h"
#import "FloorUpdateViewController.h"
#import "DocumentsListViewController.h"

@implementation RootViewController
@synthesize sectionNames;
@synthesize sectionIcons;
@synthesize popoverController;
@synthesize rootPopoverButtonItem;

-(NSArray *)sectionNames {
    if (!sectionNames) {
        self.sectionNames = [NSArray arrayWithObjects:
                                @"Floor Updates",
                                @"Whip Notices", 
                                @"Hearings",
                                @"Documents",
                                @"About", nil];
    }
    return sectionNames;
}

-(NSArray *)sectionIcons {
    if (!sectionIcons) {
        self.sectionIcons = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"56-feed.png"],
                                [UIImage imageNamed:@"166-newspaper.png"],
                                [UIImage imageNamed:@"146-gavel.png"],
                                [UIImage imageNamed:@"179-notepad.png"],
                                [UIImage imageNamed:@"59-info.png"], nil];
    }
    return sectionIcons;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Main Menu";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
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

#pragma mark - Split View Controller Delegate methods

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
    // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = @"Main Menu";
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
    //If the detail view is a navigation controller, check to see if the underlying view controller supports popovers
    if ([[self.splitViewController.viewControllers objectAtIndex:1] isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navController = [self.splitViewController.viewControllers objectAtIndex:1];
        id detailViewController = [navController visibleViewController];
        if ([detailViewController conformsToProtocol:@protocol(PopoverSupportingViewController)]) {
            [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
        }
    }
    else {
        UIViewController <PopoverSupportingViewController> *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
        [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
    }
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
    if ([[self.splitViewController.viewControllers objectAtIndex:1] isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navController = [self.splitViewController.viewControllers objectAtIndex:1];
        id detailViewController = [navController visibleViewController];
        if ([detailViewController conformsToProtocol:@protocol(PopoverSupportingViewController)]) {
            [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
        }
    }
    else {
        UIViewController <PopoverSupportingViewController> *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
        [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
    }
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
}

#pragma mark - UI Navigation Controller delegate methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id detailViewController = viewController;
    
    //When popping off the navigation stack, ensure that the popover button disappears in landscape orientation
    if ((viewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (viewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        if ([viewController conformsToProtocol:@protocol(PopoverSupportingViewController)]) {
            if (viewController.navigationController.navigationBar.topItem.leftBarButtonItem != nil) {
                [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
                NSLog(@"Hide called for conforming VC");
            }
        }
    }
    else {
        //Otherwise, ensure that the popover button appears in portrait orientation
        if ([viewController conformsToProtocol:@protocol(PopoverSupportingViewController)]) {
            [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
        }
    }
}


 // Override to allow orientations other than the default portrait orientation.
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


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionNames count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [self.sectionIcons objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.sectionNames objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Conditionally push view controllers
    // If the device is an iPad, push the appropriate view controller into the detail view
    // If the device is an iPhone/iPod Touch, push the appropriate view controller onto the nav stack
    UIViewController <PopoverSupportingViewController> *detailViewController = nil;
    if (indexPath.row == 0) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            FloorUpdateViewController *floorUpdateController = [[FloorUpdateViewController alloc] initWithNibName:@"FloorUpdateViewController-iPad" bundle:nil];
            UINavigationController *floorUpdateNavController = [[UINavigationController alloc] initWithRootViewController:floorUpdateController];
            detailViewController = floorUpdateController;
            NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, floorUpdateNavController, nil];
            self.splitViewController.viewControllers = viewControllers;
            [viewControllers release];
        }
        else {
            FloorUpdateViewController *floorUpdateController = [[FloorUpdateViewController alloc] initWithNibName:@"FloorUpdateViewController" bundle:nil];
            [self.navigationController pushViewController:floorUpdateController animated:YES];
            [floorUpdateController release];
        }
    }
    
    else if (indexPath.row == 1) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            WhipNoticeViewController *whipController = [[WhipNoticeViewController alloc] initWithNibName:@"WhipNoticeViewController" bundle:nil];
            UINavigationController *noticeNavController = [[UINavigationController alloc] initWithRootViewController:whipController];
            detailViewController = whipController;
            noticeNavController.delegate = self;
            NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, noticeNavController, nil];
            self.splitViewController.viewControllers = viewControllers;
            [viewControllers release];
        }
        else {
            WhipNoticeViewController *whipController = [[WhipNoticeViewController alloc] initWithNibName:@"WhipNoticeViewController" bundle:nil];
            [self.navigationController pushViewController:whipController animated:YES];
            [whipController release];   
        }
    }
    
    else if (indexPath.row == 2) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // Pushes the Committee Hearings view controller
            CommitteeHearingsViewController *hearingsController = [[CommitteeHearingsViewController alloc] initWithNibName:@"CommitteeHearingsViewController-iPad" bundle:nil];
            UINavigationController *hearingsNavController = [[UINavigationController alloc] initWithRootViewController:hearingsController];
            detailViewController = hearingsController;
            NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, hearingsNavController, nil];
            self.splitViewController.viewControllers = viewControllers;
            [viewControllers release];
        }
        else {
            CommitteeHearingsViewController *hearingsController = [[CommitteeHearingsViewController alloc] initWithNibName:@"CommitteeHearingsViewController" bundle:nil];
            [self.navigationController pushViewController:hearingsController animated:YES];
            [hearingsController release];
        }
    }
    
    else if (indexPath.row == 3) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            DocumentsListViewController *documentsController = [[DocumentsListViewController alloc] initWithNibName:@"DocumentsListViewController" bundle:nil];
            UINavigationController *docListNavController = [[UINavigationController alloc] initWithRootViewController:documentsController];
            detailViewController = documentsController;
            NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, docListNavController, nil];
            self.splitViewController.viewControllers = viewControllers;
            [viewControllers release];
        }
        else {
            // Pushes the Documents List view controller
            DocumentsListViewController *documentsController = [[DocumentsListViewController alloc] initWithNibName:@"DocumentsListViewController" bundle:nil];
            [self.navigationController pushViewController:documentsController animated:YES];
            [documentsController release];
        }
    }
    
    else if (indexPath.row == 4) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // Pushes the About Screen view controller
            AboutViewController *aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            UINavigationController *aboutNavController = [[UINavigationController alloc] initWithRootViewController:aboutController];
            detailViewController = aboutController;
            NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, aboutNavController, nil];
            self.splitViewController.viewControllers = viewControllers;
            [viewControllers release];
        }
        else {
            // Pushes the About Screen view controller
            AboutViewController *aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:aboutController animated:YES];
            [aboutController release];
        }
    }
    
    // Dismiss the popover if it's present.
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }
    
    // Configure the new view controller's popover button (after the view has been displayed and its navigation bar has been created).
    if (rootPopoverButtonItem != nil) {
        [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
    }
    
    [detailViewController release];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
    [popoverController release];
    [rootPopoverButtonItem release];
}

@end
