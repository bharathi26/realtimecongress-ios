//
//  AboutViewController.m
//  RealTimeCongress
//
//  Created by Tom Tsai on 5/24/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "AboutViewController.h"
#import "GANTracker.h"


@implementation AboutViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [webView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Add the popover button to the left navigation item.
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
    NSLog(@"About: Show Main Menu Button");
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    // Remove the popover button.
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:nil animated:NO];
    NSLog(@"About: Hide Main Menu Button");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"About";
    
    //Set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Loads the HTML file from the application bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AboutInfo" ofType:@"html"];
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSString *htmlString = [[NSString alloc] initWithData: 
                            [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];

    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    [htmlString release];
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
    
    NSError *error;
    //Register a page view to the Google Analytics tracker
    if (![[GANTracker sharedTracker] trackPageview:@"/about"
                                         withError:&error]) {
        // Handle error here
    }
    
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

@end
