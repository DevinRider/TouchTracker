//
//  DEVDrawView.m
//  TouchTracker
//
//  Created by Devin on 6/12/14.
//  Copyright (c) 2014 Devin Rider. All rights reserved.
//

#import "DEVDrawView.h"
#import "DEVLine.h"

@interface DEVDrawView ()

@property (nonatomic) NSMutableDictionary *linesInProgress;
@property (nonatomic) NSMutableArray *finishedLines;

@property (nonatomic, weak) DEVLine *selectedLine;

@end

@implementation DEVDrawView


#pragma mark - Initializers
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(doubleTap:)];
        doubleTapRecognizer.delaysTouchesBegan = YES;
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

#pragma mark - Drawing the lines
- (void)strokeLine: (DEVLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect
{
    //draw finished lines in black
    [[UIColor blackColor] set];
    for(DEVLine *line in self.finishedLines){
        [self strokeLine:line];
    }
    
    [[UIColor redColor] set];
    for(NSValue *key in self.linesInProgress){
        [self strokeLine:self.linesInProgress[key]];
    }
    if(self.selectedLine){
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

#pragma mark - Handling the location of the lines
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    for(UITouch *t in touches){
        CGPoint location = [t locationInView:self];
        
        DEVLine *line = [[DEVLine alloc] init];
        line.begin = location;
        line.end = location;
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //log it
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for(UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        DEVLine *line = self.linesInProgress[key];
        
        line.end = [t locationInView:self];
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //log it
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for(UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        DEVLine *line = self.linesInProgress[key];
        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //log it
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for(UITouch *t in touches){
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }
    [self setNeedsDisplay];
}

- (DEVLine *)lineAtPoint:(CGPoint)p
{
    //find a line close to p
    for (DEVLine *line in self.finishedLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        //check a few point on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x -start.x);
            float y = start.y + t * (end.y -start.y);
            //if the tapped point is within 20 points, let's return this line
            if (hypot(x - p.x, y - p.y) < 20) {
                return line;
            }
        }
    }
    return nil;
}

#pragma mark - UITapGestureRecognizer actions
- (void)doubleTap:(UITapGestureRecognizer *)gr
{
    NSLog(@"Double Tap Recognized");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)tap:(UITapGestureRecognizer *)gr
{
    NSLog(@"Recognized Tap");
    CGPoint point = [gr locationInView:self];
    
    self.selectedLine = [self lineAtPoint:point];
    
    [self setNeedsDisplay];
    
    if(self.selectedLine) {
        //make ourselves the target of menu item action messages
        [self becomeFirstResponder];
        
        //grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        //create a delete UImenuitem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        //tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2)
                     inView:self];
        [menu setMenuVisible:YES
                    animated:YES];
    }
    else {
        [[UIMenuController sharedMenuController] setMenuVisible:NO
                                                       animated:YES];
    }
}

- (void)deleteLine:(id)sender
{
    //remove the selected line from the list of finishedLines
    [self.finishedLines removeObject:self.selectedLine];
    
    //redraw everything
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
