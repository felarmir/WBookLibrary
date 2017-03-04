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
#import <Quartz/Quartz.h>

@interface EPubViewController ()<EPubParserDeleage, WebUIDelegate, WebResourceLoadDelegate, WebFrameLoadDelegate>

@end

@implementation EPubViewController
{
    AppDelegate *appDelegate;
    EPubParser *epubBookParser;
    NSArray *spines;
    NSDictionary *manifest;
    CGFloat scrollPosition;
    int spineIndex;
    BOOL isBackOnSpine;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[NSApplication sharedApplication] delegate];
    CGSize wsize = [[DataConfigLoader singleInstance] getFrameWindowSize];
    [self.view setFrameSize:wsize];
    
    [[[_epubContentView mainFrame] frameView] setAllowsScrolling:NO];
    _epubContentView.frameLoadDelegate = self;
    
    scrollPosition = 0.0;
    spineIndex = 0;
    isBackOnSpine = false;
    
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
    NSURL *url = [NSURL fileURLWithPath:[manifest objectForKey:[spines objectAtIndex:spineIndex]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [[_epubContentView mainFrame] loadRequest:request];
}


-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    [[[[_epubContentView mainFrame] frameView] documentView] enclosingScrollView].verticalScrollElasticity=NSScrollElasticityNone;
    
    
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"
    "}"
    "}";
    NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
    NSString *hrefStyle = @"addCSSRule('a', 'text-decoration: none;')";
    NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', 'font-size: %d%%; padding-left:20px;padding-right:20px;')", 100];

    [_epubContentView stringByEvaluatingJavaScriptFromString:varMySheet];
    [_epubContentView stringByEvaluatingJavaScriptFromString:addCSSRule];
    [_epubContentView stringByEvaluatingJavaScriptFromString:insertRule2];
    [_epubContentView stringByEvaluatingJavaScriptFromString:hrefStyle];
    [_epubContentView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    
    if (isBackOnSpine) {
        scrollPosition = [[[_epubContentView mainFrame] frameView] documentView].frame.size.height;
        [[[[_epubContentView mainFrame] frameView] documentView] scrollPoint:NSMakePoint(0, scrollPosition)];
    }

}

-(IBAction)nextPagePress:(id)sender {
    NSLog(@"==>%i=%f == %f", spineIndex,[[[_epubContentView mainFrame] frameView] documentView].frame.size.height,self.view.bounds.size.height);
    scrollPosition += self.view.bounds.size.height;
    if([[[_epubContentView mainFrame] frameView] documentView].frame.size.height == self.view.bounds.size.height) {
        if(spineIndex < [spines count]) {
            spineIndex++;
            isBackOnSpine = NO;
            scrollPosition = 0;
            [self loadBook];
        }
    } else if([[[_epubContentView mainFrame] frameView] documentView].frame.size.height >= scrollPosition) {
        [[[[_epubContentView mainFrame] frameView] documentView] scrollPoint:NSMakePoint(0, scrollPosition)];
    } else  {
        if(spineIndex < [spines count]) {
            spineIndex++;
            isBackOnSpine = NO;
            scrollPosition = 0;
            [self loadBook];
        }
    }
}

-(IBAction)backPagePress:(id)sender {
    scrollPosition -= self.view.bounds.size.height;
    if (scrollPosition <= (0 - (self.view.bounds.size.height))) {
        if(spineIndex > 0) {
            spineIndex--;
            isBackOnSpine = YES;
            scrollPosition = 0;
            [self loadBook];
        }
    } else if (scrollPosition < (0 - (self.view.bounds.size.height/2))) {
        scrollPosition = 0;
        [[[[_epubContentView mainFrame] frameView] documentView] scrollPoint:NSMakePoint(0, 0)];
    } else {
        [[[[_epubContentView mainFrame] frameView] documentView] scrollPoint:NSMakePoint(0, scrollPosition)];
    }

}

@end
