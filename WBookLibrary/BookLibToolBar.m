//
//  BookLibToolBar.m
//  WBookLibrary
//
//  Created by Denis Andreev on 26/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "BookLibToolBar.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@implementation BookLibToolBar
{
    AppDelegate *appDelegate;
}

-(IBAction)loadBookLibrary:(id)sender {
    appDelegate = [[NSApplication sharedApplication] delegate];
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *mainView = [storyboard instantiateControllerWithIdentifier:@"MainViewController"];
    appDelegate.window.contentViewController = mainView;
}

@end
