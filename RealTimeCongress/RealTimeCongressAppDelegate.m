#import "RealTimeCongressAppDelegate.h"
#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = -1; //Manual dispatch

@implementation RealTimeCongressAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Start up the Google Analytics tracker object
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-1265484-75"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    //Set Dry Run flag for testing
    [GANTracker sharedTracker].dryRun = YES;
    
    //Set Debug flag for test
    [GANTracker sharedTracker].debug = YES;
    
    //Set status bar color to black
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    //Set up the shared URL Cache
    [NSURLCache sharedURLCache];
    
    // Add the navigation controller's view to the window and display
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //Dispatch batched tracking requests
    [[GANTracker sharedTracker] dispatch];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
