//
//  DrawView.m
//  TouchTracker
//
//  Created by Princess Sampson on 9/18/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

#import "DrawView.h"
#import "Line.h"

@implementation DrawView

- (void)strokeLine:(Line*)line {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 10;
    path.lineCapStyle = kCGLineCapRound;
    
    [path moveToPoint:line.begin];
    [path addLineToPoint:line.end];
    [path stroke];
}


- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setStroke];
    
    for (Line* line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    for (Line* line in self.currentLines.allValues) {
        [[UIColor redColor] setStroke];
        [self strokeLine:line];
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        Line *line = [[Line alloc] initWithBegin:location end:location];
        
        self.currentLines[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        Line *line = self.currentLines[key];
        line.end = location;
        
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        Line *line = self.currentLines[key];
        line.end = location;
        
        [self.finishedLines addObject:line];
        [self.currentLines removeObjectForKey:key];
        
    }
    
    [self setNeedsDisplay];
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _finishedLines = [[NSMutableArray alloc] init];
        _currentLines = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

@end
