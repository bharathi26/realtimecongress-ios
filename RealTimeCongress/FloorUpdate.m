//
//  FloorUpdate.m
//  RealTimeCongress
//
//  Created by Stephen Searles on 6/4/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import "FloorUpdate.h"


@implementation FloorUpdate

#define kTextViewFontSize        17.0 //This matches the height of the font in the UITextView in the nib (FloorUpdateTableViewCell.xib)

@synthesize displayText = _displayText;
@synthesize date = _date;
@synthesize displayDate = _displayDate;
@synthesize displayTextWithDate = _displayTextWithDate;
@synthesize textHeight = _textHeight;
@synthesize textViewHeightRequired;
@synthesize bills = _bills;
@synthesize hasAbbreviations;

- (id)initWithDisplayText:(NSString *)text atDate:(NSDate *)date withCellWidth: (int)cellWidth{
    self = [super init];
    if (self) {
        _displayText = [text copy];
        _date = [date copy];
        _textHeight = -1;
        _bills = [[NSMutableSet alloc] initWithCapacity:5];
        cellWidthConstraint = cellWidth;
    }
    return self;
}

- (NSString *)displayTextWithDate {
    if (!_displayTextWithDate) {
        NSDateFormatter * dateFormatPrinter = [[NSDateFormatter alloc] init];
        [dateFormatPrinter setDateFormat:@"MMMM dd, yyyy h:mm aa"];
        [dateFormatPrinter setTimeZone:[NSTimeZone systemTimeZone]];
        _displayTextWithDate = [[NSString alloc] initWithFormat:@"%@\n%@",[dateFormatPrinter stringFromDate:_date],_displayText];
        [dateFormatPrinter release];
    }
    return _displayTextWithDate;
}

- (NSString *)displayDate {
    if (!_displayDate) {
        NSDateFormatter * dateFormatPrinter = [[NSDateFormatter alloc] init];
        [dateFormatPrinter setDateFormat:@"h:mm aa"];
        [dateFormatPrinter setTimeZone:[NSTimeZone systemTimeZone]];
        _displayDate = [[NSString alloc] initWithFormat:@"%@",[dateFormatPrinter stringFromDate:_date]];
        [dateFormatPrinter release];
    }
    return _displayDate;
}

- (CGFloat)textHeight {
    if (_textHeight == -1) {
        _textHeight = [_displayText sizeWithFont:[UIFont systemFontOfSize:kTextViewFontSize] constrainedToSize:CGSizeMake(cellWidthConstraint, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    }
    return _textHeight;
}

- (CGFloat)textViewHeightRequired {
    return [self textHeight] + 15;
}

- (BOOL)hasAbbreviations {
    if ([_bills count] > 0)
        return YES;
    else
        return NO;
}

- (void)dealloc
{
    [_displayTextWithDate release];
    [_displayText release];
    [_date release];
    [_bills release];
    [super dealloc];
}

@end
