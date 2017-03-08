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
#import "ToolBarHandlers.h"

@interface PDFViewer ()<NSToolbarDelegate>

@end

@implementation PDFViewer
{
    AppDelegate *appDelegate;
    PDFDocument *pdfDoc;
    ToolBarHandlers *toolHandlers;
    NSArray<NSToolbarItem*> *toolBarItems;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[NSApplication sharedApplication] delegate];
    appDelegate.window.titlebarAppearsTransparent = NO;
    CGSize wsize = [[DataConfigLoader singleInstance] getFrameWindowSize];
    [self.view setFrameSize:wsize];
    toolHandlers = [[ToolBarHandlers alloc] init];
    NSURL *url = [NSURL fileURLWithPath:_bookURL];
    pdfDoc = [[PDFDocument alloc] initWithURL:url];
    NSString *title = [[pdfDoc documentAttributes] objectForKey:@"Title"];
    if (title == nil) {
        title = @"unknown title";
    }
    self.title = title;
    [appDelegate.window setTitle:title];
    [_pdfView setDocument:pdfDoc];
    [_pdfView setAutoScales:YES];
    
    NSToolbar *toolBar = [[NSToolbar alloc] initWithIdentifier:@"PDFViewToolBar"];
    [toolBar setDelegate:self];
    [appDelegate.window setToolbar:toolBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDelegate.window];
}

-(void)resizeWindow {
    [[DataConfigLoader singleInstance] setWindowSize:self.view.frame.size];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:
(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{

    NSToolbarItem *newItem = nil;
    NSButton *btn = nil;
    
    if([itemIdentifier isEqualToString:@"Library"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        btn = [NSButton buttonWithImage:[NSImage imageNamed:@"booklib"] target:self action:@selector(returnToLibrary)];
        [newItem setLabel:@"Library"];
        [newItem setPaletteLabel:@"Library"];

    } else if([itemIdentifier isEqualToString:@"TwoPage"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        btn = [NSButton buttonWithImage:[NSImage imageNamed:@"twoPage"] target:self action:@selector(setTwoPage)];
        [newItem setLabel:@"Two Page"];
        [newItem setPaletteLabel:@"Two Page"];
        
    } else if([itemIdentifier isEqualToString:@"OnePage"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        btn = [NSButton buttonWithImage:[NSImage imageNamed:@"onePage"] target:self action:@selector(setOnePage)];
        [newItem setLabel:@"One Page"];
        [newItem setPaletteLabel:@"One Page"];
        
    }
    
    [newItem setView:btn];
    [btn setBezelStyle:NSRegularSquareBezelStyle];
    [btn setFrame:NSMakeRect(0, 0, 32, 32)];
    
    NSSize minSize = NSMakeSize(32, 32);
    [newItem setMaxSize:minSize];
    return newItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Library",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"OnePage", @"TwoPage", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Library",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"OnePage", @"TwoPage", nil];
}

-(void)returnToLibrary {
    [toolHandlers loadCatalogue];
}

-(void)nextPage:(id)sender {
    [_pdfView goToNextPage:sender];
}

-(void)setTwoPage {
    [_pdfView setDisplayMode:kPDFDisplayTwoUpContinuous];
}

-(void)setOnePage {
    [_pdfView setDisplayMode:kPDFDisplaySinglePageContinuous];
}

@end
