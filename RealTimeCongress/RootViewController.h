#import <UIKit/UIKit.h>

@protocol PopoverSupportingViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end

@interface RootViewController : UITableViewController <UISplitViewControllerDelegate>{
    UIPopoverController *popoverController;    
    UIBarButtonItem *rootPopoverButtonItem;

}
@property(nonatomic,copy) NSArray *sectionNames;
@property(nonatomic,copy) NSArray *sectionIcons;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;

@end
