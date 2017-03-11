//
//  CollectionViewSectionHeader.m
//  WBookLibrary
//
//  Created by Denis Andreev on 11/03/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "CollectionViewSectionHeader.h"

@implementation CollectionViewSectionHeader

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.layer setBackgroundColor:[NSColor clearColor].CGColor];
}

@end
