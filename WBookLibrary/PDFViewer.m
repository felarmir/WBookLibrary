//
//  PDFViewer.m
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "PDFViewer.h"
#import "AppDelegate.h"
#import "DataConfigLoader.h"

@interface PDFViewer ()

@end

@implementation PDFViewer
{
    AppDelegate *appDelegate;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[NSApplication sharedApplication] delegate];
    CGSize wsize = [[DataConfigLoader singleInstance] getFrameWindowSize];
    [self.view setFrameSize:wsize];
    
    NSURL *url = [NSURL fileURLWithPath:_bookURL];
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    NSString *title = [[pdfDoc documentAttributes] objectForKey:@"Title"];
    if (title == nil) {
        title = @"unknown title";
    }
    self.title = title;
    [appDelegate.window setTitle:title];
    [_pdfView setDocument:pdfDoc];
    [_pdfView setAutoScales:YES];
    
}

@end
