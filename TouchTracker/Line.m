//
//  Line.m
//  TouchTracker
//
//  Created by Princess Sampson on 9/18/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

#import "Line.h"

@implementation Line

- (instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end {
    self = [super init];
    
    if(self) {
        _begin = begin;
        _end = end;
    }
    
    return self;
}

@end
