//
//  DrawView.h
//  TouchTracker
//
//  Created by Princess Sampson on 9/18/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface DrawView : UIView
@property(nonatomic) NSMutableArray* finishedLines;
@property(nonatomic) NSMutableDictionary* currentLines;

@end
