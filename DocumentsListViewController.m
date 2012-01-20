//
//  DocumentsListViewController.m
//  RealTimeCongress
//
//  Created by Tom Tsai on 8/8/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "DocumentsListViewController.h"
#import "CRSReportViewController.h"
#import "CBOEstimateViewController.h"
#import "GAOReportViewController.h"

@implementation DocumentsListViewController

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
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Documents";
    //Set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    
    //iPad supports all orientations
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        //iPhone supports only portrait orientation
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"CRS Reports";
            break;
            
        case 1:
            cell.textLabel.text = @"CBO Estimates";
            break;
        case 2:
            cell.textLabel.text = @"GAO Reports";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CRSReportViewController *crsReportViewController = [[CRSReportViewController alloc] initWithNibName:@"CRSReportViewController" bundle:nil];
        [self.navigationController pushViewController:crsReportViewController animated:YES];
        [crsReportViewController release];
    }
    else if (indexPath.row == 1) {
        CBOEstimateViewController *cboEstimateViewController = [[CBOEstimateViewController alloc] initWithNibName:@"CBOEstimateViewController" bundle:nil];
        [self.navigationController pushViewController:cboEstimateViewController animated:YES];
        [cboEstimateViewController release];
    }
    else if (indexPath.row == 2) {
        GAOReportViewController *gaoReportViewController = [[GAOReportViewController alloc] initWithNibName:@"GAOReportViewController" bundle:nil];
        [self.navigationController pushViewController:gaoReportViewController animated:YES];
        [gaoReportViewController release];
    }
    
}

@end
