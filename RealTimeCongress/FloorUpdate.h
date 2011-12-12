//
//  FloorUpdate.h
//  RealTimeCongress
//
//  Created by Stephen Searles on 6/4/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bill.h"
#import "CongressionalArtifact.h"

@interface FloorUpdate : CongressionalArtifact {
@private
    NSString * _displayText;
    NSString * _displayTextWithDate;
    NSDate * _date;
    NSString * _displayDate;
    CGFloat _textHeight;
    int cellWidthConstraint;
    
    NSMutableSet * _bills;
}

@property (readonly) NSString * displayText;
@property (readonly) NSDate * date;
@property (readonly) NSString * displayDate;
@property (readonly) NSString * displayTextWithDate;
@property (readonly) CGFloat textHeight;
@property (readonly) CGFloat textViewHeightRequired;
@property (readonly) NSSet * bills;
@property (readonly) BOOL hasAbbreviations;

- (id)initWithDisplayText:(NSString *)text atDate:(NSDate *)date withCellWidth: (int) cellWidth;

@end
