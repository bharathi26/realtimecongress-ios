//
//  WhipNoticesWebViewController.m
//  RealTimeCongress
//
//  Created by Tom Tsai on 6/14/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "WhipNoticesWebViewController.h"
#import "GANTracker.h"


@implementation WhipNoticesWebViewController

@synthesize urlRequest;
@synthesize loadingIndicator;

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
    [webView loadRequest:urlRequest];
    
    webView.scalesPageToFit = YES;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:webView  action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error;
    //Register a page view to the Google Analytics tracker
    if (![[GANTracker sharedTracker] trackPageview:@"/whipnotices/webview"
                                         withError:&error]) {
        // Handle error here
    }
    
    //An activity indicator to indicate loading
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingIndicator setCenter:self.view.center];
    [self.view addSubview:loadingIndicator];
    
    // Set the view controller as the web view's delegate
    webView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    webView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Web View delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Animate the activity indicator to indicate loading
    [self.loadingIndicator startAnimating];
    
    // Show the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Stop animating the activity indicator to indicate loading complete
    [loadingIndicator stopAnimating];
    
    // Stop showing the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{}


@end
