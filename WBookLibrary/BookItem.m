//
//  BookItem.m
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "BookItem.h"

@interface BookItem ()

@end

@implementation BookItem

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(selected) {
        [self.view.layer setShadowColor:[NSColor blueColor].CGColor];
        [self.view.layer setShadowOpacity:0.5];
        [self.view.layer setShadowRadius:10.0];
        [self.view setNeedsDisplay:YES];
    } else {
        [self.view.layer setShadowOpacity:0.0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
