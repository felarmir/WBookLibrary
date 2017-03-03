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

@interface EPubViewController ()<EPubParserDeleage, WebUIDelegate, WebResourceLoadDelegate, WebFrameLoadDelegate>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDelegate.window];

}

-(void)resizeWindow {

}

-(void)parseFinish:(NSDictionary*)epubDataInfo {
    spines = [epubDataInfo objectForKey:@"spine"];
    manifest = [epubDataInfo objectForKey:@"manifest"];
    [self loadBook];
}

-(void)loadBook {
    NSURL *url = [NSURL fileURLWithPath:[manifest objectForKey:[spines objectAtIndex:2]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [[_epubContentView mainFrame] loadRequest:request];
    [[_epubContentView preferences] setDefaultFontSize:20.f];
    _epubContentView.frameLoadDelegate = self;

}


-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
    "}";

    [_epubContentView stringByEvaluatingJavaScriptFromString:varMySheet];
    [_epubContentView stringByEvaluatingJavaScriptFromString:addCSSRule];
}

-(IBAction)nextPagePress:(id)sender {
    
}

@end
