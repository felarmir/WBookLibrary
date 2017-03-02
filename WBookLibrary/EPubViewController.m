//
//  EPubViewController.m
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "EPubViewController.h"
#import "EPubParser.h"

@interface EPubViewController ()<EPubParserDeleage>

@end

@implementation EPubViewController
{
    EPubParser *epubBookParser;
    NSArray *spines;
    NSDictionary *manifest;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSURL *url = [NSURL URLWithString:[manifest objectForKey:[spines objectAtIndex:0]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[_epubContentView mainFrame] loadRequest:request];
}

@end
