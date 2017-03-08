//
//  ToolBarHandlers.m
//  WBookLibrary
//
//  Created by Denis Andreev on 08/03/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "ToolBarHandlers.h"
#import "AppDelegate.h"

@implementation ToolBarHandlers
{
    AppDelegate *appDelegate;
    NSStoryboard *storyboard;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = [[NSApplication sharedApplication] delegate];
        storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    return self;
}

-(void)loadCatalogue {
    appDelegate.window.contentViewController = [storyboard instantiateControllerWithIdentifier:@"MainViewController"];
}

@end
