//
//  PDFViewer.h
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@interface PDFViewer : NSViewController<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSColorWell *markColor;


@property (weak) IBOutlet PDFView *pdfView;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSString *bookURL;

- (IBAction)markText:(id)sender;

@end
