//
//  WhipNoticesWebViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 6/14/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WhipNoticesWebViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UIWebView *webView;
    NSURLRequest *urlRequest;
}

@property (nonatomic, retain) NSURLRequest *urlRequest;

@end
