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

- (void)deleteLine:(id)sender {
    if(self.selectedLine) {
        [self.finishedLines removeObject:self.selectedLine];
        [self setNeedsDisplay];
    }
}

- (void)tap:(UIGestureRecognizer*)gestureRecognizer {
    NSLog(@"Recognized a tap");
    
    CGPoint point = [gestureRecognizer locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    if(self.selectedLine) {
        [self becomeFirstResponder];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                        action:@selector(deleteLine:)];
        menu.menuItems = @[delete];
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        [menu setMenuVisible:NO animated:YES];
    
    }
    
    [self setNeedsDisplay];
}

- (void)doubleTap:(UIGestureRecognizer*)gestureRecognizer {
    NSLog(@"Recognized a doubletap");
    
    [self.currentLines removeAllObjects];
    [self.finishedLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self];
        
        self.selectedLine = [self lineAtPoint:point];
        
        if(self.selectedLine) {
            [self.currentLines removeAllObjects];
        }
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    
    [self setNeedsDisplay];

}

- (void)moveLine:(UIPanGestureRecognizer*)gestureRegognizer {
    Line *line = self.selectedLine;
    
    if (line) {
        
        if(gestureRegognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRegognizer translationInView:self];
           
            CGPoint begin = line.begin;
            begin.x += translation.x;
            begin.y += translation.y;
            line.begin = begin;
            
            CGPoint end = line.end;
            end.x += end.x;
            end.y += end.y;
            line.end = end;
            
            [gestureRegognizer setTranslation:CGPointZero inView:self];
            [self setNeedsDisplay];
        }
        
    } else {
        return;
    }
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
    
    if(self.selectedLine) {
        [[UIColor greenColor] setStroke];
        [self strokeLine:self.selectedLine];
    }
}

- (Line*)lineAtPoint:(CGPoint)point {
    
    for (Line* line in self.finishedLines) {
        CGPoint begin = line.begin;
        CGPoint end = line.end;
        
        for (CGFloat t = 0; t < 1.0; t += 0.05) {
            CGFloat x = begin.x + ((end.x - begin.x) * t);
            CGFloat y = begin.y + ((end.y - begin.y) * t);
            
            if (hypot(x - point.x, y - point.x) < 20.0) {
                return line;
            }
        }
    }
    
    return nil;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    
    return NO;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _finishedLines = [[NSMutableArray alloc] init];
        _currentLines = [[NSMutableDictionary alloc] init];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(doubleTap:)];
        doubleTapRecognizer.delaysTouchesBegan = YES;
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(tap:)];
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        tapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                    initWithTarget:self
                                                                    action:@selector(longPress:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        _moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(moveLine:)];
        _moveRecognizer.delegate = self;
        _moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_moveRecognizer];
        
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end
