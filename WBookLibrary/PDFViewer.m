//
//  PDFViewer.m
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "PDFViewer.h"

@interface PDFViewer ()

@end

@implementation PDFViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL fileURLWithPath:_bookURL];
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    self.title = [[pdfDoc documentAttributes] objectForKey:@"Title"];
    [_pdfView setDocument:pdfDoc];
    [_pdfView setAutoScales:YES];
    
}

@end
