//
//  WhipNoticesWebViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 6/14/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WhipNoticesWebViewController : UIViewController <UIWebViewDelegate>{
    @private
    IBOutlet UIWebView *webView;
    NSURLRequest *urlRequest;
    UIActivityIndicatorView *loadingIndicator;
    NSString *launchType;
    UIBarButtonItem *refreshButton;
}

@property (nonatomic, retain) NSURLRequest *urlRequest;
@property(nonatomic,retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) NSString *launchType;
@property (nonatomic, assign) UIBarButtonItem *refreshButton;

@end
