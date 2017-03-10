//
//  BookItemView.m
//  WBookLibrary
//
//  Created by Wiirlock on 27.02.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "BookItemView.h"

@implementation BookItemView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:_startColor
                                                         endingColor:_endColor];
    NSBezierPath *bpath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0.0 yRadius:0.0];
    [gradient drawInBezierPath:bpath angle:90.0];
    [self.layer setCornerRadius: 3.0];
}

@end
