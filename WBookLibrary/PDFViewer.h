//
//  PDFViewer.h
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@interface PDFViewer : NSViewController

@property (weak) IBOutlet PDFView *pdfView;

@property (nonatomic, strong) NSString *bookURL;


@end
