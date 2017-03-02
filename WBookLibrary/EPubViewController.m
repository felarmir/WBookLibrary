//
//  EPubViewController.m
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "EPubViewController.h"
#import "EPubParser.h"
#import "AppDelegate.h"
#import "DataConfigLoader.h"

@interface EPubViewController ()<EPubParserDeleage>

@end

@implementation EPubViewController
{
    AppDelegate *appDelegate;
    EPubParser *epubBookParser;
    NSArray *spines;
    NSDictionary *manifest;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[NSApplication sharedApplication] delegate];
    CGSize wsize = [[DataConfigLoader singleInstance] getFrameWindowSize];
    [self.view setFrameSize:wsize];
    
    epubBookParser = [[EPubParser alloc] init];
    [epubBookParser setDelegate:self];
    [epubBookParser epubFileLoader:_bookPath destination:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"dionistmp"]];
    
}

-(void)parseFinish:(NSDictionary*)epubDataInfo {
    spines = [epubDataInfo objectForKey:@"spine"];
    manifest = [epubDataInfo objectForKey:@"manifest"];
    [self loadBook];
}

-(void)loadBook {
    NSURL *url = [NSURL fileURLWithPath:[manifest objectForKey:[spines objectAtIndex:2]]];
    NSAttributedString *text = [[NSAttributedString alloc] initWithURL:url options:nil documentAttributes:nil error:nil];
    [_epubContentView.textStorage setAttributedString:text];
}

@end
