//
//  Line.h
//  TouchTracker
//
//  Created by Princess Sampson on 9/18/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Line : NSObject
@property(nonatomic) CGPoint begin;
@property(nonatomic) CGPoint end;

- (instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end;

@end
