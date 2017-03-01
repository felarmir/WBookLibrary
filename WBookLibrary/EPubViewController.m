//
//  EPubViewController.m
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "EPubViewController.h"
#import "EPubParser.h"

@interface EPubViewController ()

@end

@implementation EPubViewController
{
    EPubParser *epubBookParser;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    epubBookParser = [[EPubParser alloc] init];
    [epubBookParser epubFileLoader:_bookPath destination:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"dionistmp"]];
}

@end
