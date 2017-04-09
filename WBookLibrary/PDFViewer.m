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
#import "PDFMarks+CoreDataProperties.h"

@interface PDFViewer ()<NSToolbarDelegate, NSSplitViewDelegate>

@end

@implementation PDFViewer
{
    AppDelegate *appDelegate;
    PDFDocument *pdfDoc;
    ToolBarHandlers *toolHandlers;
    NSArray<NSToolbarItem*> *toolBarItems;
    NSMutableArray<PDFSelection*> *selectionText;
    NSArray *markData;
    BOOL isShowTools;
    NSTextField *pageField;
    NSString *bookInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[NSApplication sharedApplication] delegate];
    appDelegate.window.titlebarAppearsTransparent = NO;
    CGSize wsize = [[DataConfigLoader singleInstance] getFrameWindowSize];
    [self.view setFrameSize:wsize];
    isShowTools = false;
    
    toolHandlers = [[ToolBarHandlers alloc] init];
    NSURL *url = [NSURL fileURLWithPath:_bookURL];
    pdfDoc = [[PDFDocument alloc] initWithURL:url];
    selectionText = [[NSMutableArray alloc] init];
    NSString *title = [[pdfDoc documentAttributes] objectForKey:@"Title"];
    if (title == nil) {
        title = @"unknown title";
    }

    [_splitView setDelegate:self];

    [self collapseRightView];
    
    self.title = title;
    [appDelegate.window setTitle:title];
    [_pdfView setDocument:pdfDoc];
    [_pdfView setAutoScales:YES];
    PDFPage *page = [pdfDoc pageAtIndex:[[DataConfigLoader singleInstance] getPagePositin:[_bookURL lastPathComponent]]];
    [_pdfView goToPage:page];
    bookInfo = [NSString stringWithFormat:@"Page:%@ of %lu", [page label], [pdfDoc pageCount]];

    NSToolbar *toolBar = [[NSToolbar alloc] initWithIdentifier:@"PDFViewToolBar"];
    [toolBar setDelegate:self];
    [appDelegate.window setToolbar:toolBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDelegate.window];
    
    [[_pdfView enclosingScrollView] setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollDocument) name:NSViewBoundsDidChangeNotification object:[_pdfView enclosingScrollView]];
    
    [self highlightedLoad];
    
}

-(void)highlightedLoad {
    markData = [[DataConfigLoader singleInstance] marksArrayByBookName:[_bookURL lastPathComponent]];
    if ([markData count] > 0) {
        for (PDFMarks *mark in markData) {
            PDFSelection *select = [pdfDoc findString:mark.text withOptions:NSCaseInsensitiveSearch][0];
            select.color = [NSColor colorWithRed:mark.c_red green:mark.c_green blue:mark.c_blue alpha:1.0];
            [selectionText addObject:select];
        }
    }
    _pdfView.highlightedSelections = nil;
    [_pdfView setHighlightedSelections:selectionText];
}

-(void)resizeWindow {
    [[DataConfigLoader singleInstance] setWindowSize:self.view.frame.size];
}

-(void)scrollDocument {
    [[DataConfigLoader singleInstance] addPagePositinByName:[_bookURL lastPathComponent] page:(int)[[_pdfView document] indexForPage:[_pdfView currentPage]]];
    bookInfo = [NSString stringWithFormat:@"Page:%@ of %lu", [[_pdfView currentPage] label], [pdfDoc pageCount]];
    pageField.stringValue = bookInfo;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:
(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{

    NSToolbarItem *newItem = nil;
    NSButton *btn = [[NSButton alloc] init];
    
    if([itemIdentifier isEqualToString:@"Library"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        [btn setImage:[NSImage imageNamed:@"booklib"]];
        [btn setAction:@selector(returnToLibrary:)];
        
        [newItem setLabel:@"Library"];
        [newItem setPaletteLabel:@"Library"];

    } else if([itemIdentifier isEqualToString:@"TwoPage"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [btn setImage:[NSImage imageNamed:@"twoPage"]];
        [btn setAction:@selector(setTwoPage:)];
        [newItem setLabel:@"Two Page"];
        [newItem setPaletteLabel:@"Two Page"];
        
    } else if([itemIdentifier isEqualToString:@"OnePage"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [btn setImage:[NSImage imageNamed:@"onePage"]];
        [btn setAction:@selector(setOnePage:)];
        [newItem setLabel:@"One Page"];
        [newItem setPaletteLabel:@"One Page"];
        
    } else if([itemIdentifier isEqualToString:@"ZoomIn"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [btn setImage:[NSImage imageNamed:@"zoomin"]];
        [btn setAction:@selector(zoomin:)];
        [newItem setLabel:@"Zoom In"];
        [newItem setPaletteLabel:@"Zoom In"];
        
    } else if([itemIdentifier isEqualToString:@"ZoomOut"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [btn setImage:[NSImage imageNamed:@"zoomout"]];
        [btn setAction:@selector(zoomout:)];
        [newItem setLabel:@"Zoom Out"];
        [newItem setPaletteLabel:@"Zoom Out"];
        
    } else if([itemIdentifier isEqualToString:@"Tools"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [btn setImage:[NSImage imageNamed:@"tools"]];
        [btn setAction:@selector(showInstruments:)];
        [newItem setLabel:@"Tools"];
        [newItem setPaletteLabel:@"Tools"];
        
    } else if([itemIdentifier isEqualToString:@"page"]){
        newItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        pageField = [[NSTextField alloc] init];
        pageField.stringValue = bookInfo;
        [pageField setEditable:NO];
        [pageField setBordered:NO];
        [[pageField layer] setBackgroundColor:[[NSColor clearColor] CGColor]];
        [pageField setBackgroundColor:[NSColor clearColor]];
        [pageField setAlignment:NSTextAlignmentCenter];
        [newItem setView:pageField];
        [newItem setMaxSize:NSMakeSize(120, 20)];
    }
    
    if([itemIdentifier isEqualToString:@"page"] == NO) {
        [btn setImageScaling:NSImageScaleAxesIndependently];
        [btn setBordered:NO];
        [[btn layer] setBackgroundColor:[[NSColor clearColor] CGColor]];
        [newItem setView:btn];
        [btn setBezelStyle:NSRegularSquareBezelStyle];
        [btn setFrame:NSMakeRect(0, 0, 26, 26)];
    
        NSSize minSize = NSMakeSize(26, 26);
        [newItem setMaxSize:minSize];
    }
    
    return newItem;
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Library",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"page",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"ZoomIn", @"ZoomOut",
            @"OnePage", @"TwoPage", @"Tools", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"Library",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"page",
            NSToolbarFlexibleSpaceItemIdentifier,
            @"ZoomIn", @"ZoomOut",
            @"OnePage", @"TwoPage", @"Tools", nil];
}


-(void)returnToLibrary:(id)sender {
    [toolHandlers loadCatalogue];
}

-(void)nextPage:(id)sender {
    [_pdfView goToNextPage:sender];
}

-(void)zoomin:(id)sender {
    [_pdfView zoomIn:sender];
}

-(void)zoomout:(id)sender {
    [_pdfView zoomOut:sender];
}

-(void)setTwoPage:(id)sender {
    [_pdfView setDisplayMode:kPDFDisplayTwoUpContinuous];
}

-(void)setOnePage:(id)sender {
    [_pdfView setDisplayMode:kPDFDisplaySinglePageContinuous];
}

-(void)showInstruments:(id)sender {
    if(!isShowTools) {
        [self uncollapseRightView];
    } else {
        [self collapseRightView];
    }
    isShowTools = !isShowTools;
}

-(void)collapseRightView
{
    NSView *right = [[[self splitView] subviews] objectAtIndex:1];
    NSView *left  = [[[self splitView] subviews] objectAtIndex:0];
    NSRect leftFrame = [left frame];
    NSRect overallFrame = [[self splitView] frame];
    [right setHidden:YES];
    [left setFrameSize:NSMakeSize(overallFrame.size.width,leftFrame.size.height)];
    [[self splitView] display];
}

-(void)uncollapseRightView
{
    NSView *left  = [[[self splitView] subviews] objectAtIndex:0];
    NSView *right = [[[self splitView] subviews] objectAtIndex:1];
    [right setHidden:NO];
    CGFloat dividerThickness = [[self splitView] dividerThickness];
    // get the different frames
    NSRect leftFrame = [left frame];
    NSRect rightFrame = [right frame];
    // Adjust left frame size
    leftFrame.size.width = (leftFrame.size.width-rightFrame.size.width-dividerThickness);
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;
    [left setFrameSize:leftFrame.size];
    [right setFrame:rightFrame];
    [[self splitView] display];
}

//work
-(void)addMarkonDocument {
    NSLog(@"%@",[_pdfView.currentSelection string]);
    PDFSelection *seletion = [_pdfView currentSelection];
    [seletion setColor:[_markColor color]];
    [selectionText addObject:seletion];
  
    if ([[DataConfigLoader singleInstance] addMarkByBookName:[_bookURL lastPathComponent]
                                                        page:(int)[[_pdfView document] indexForPage:[_pdfView currentPage]] text:[_pdfView.currentSelection string]
                                                    colorRed:[[_markColor color] redComponent]
                                                  colorGreen:[[_markColor color] greenComponent]
                                                   colorBlue:[[_markColor color] blueComponent]]) {
        _pdfView.highlightedSelections = nil;
        [_pdfView setHighlightedSelections:selectionText];
    }
    
}


- (IBAction)markText:(id)sender {
    [self addMarkonDocument];
}

#pragma mark NSSplitViewDelegate
/*
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return self.view.bounds.size.width - 200;
}
*/
-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return self.view.bounds.size.width - 200;;
}

#pragma mark TableView

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [markData count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    static NSString *IDENT = @"MarkCell";
    PDFMarks *mark = [markData objectAtIndex:row];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:IDENT owner:nil];
    cell.textField.stringValue = [mark text];
    [[cell layer] setBackgroundColor:[[NSColor colorWithRed:mark.c_red
                                                      green:mark.c_green
                                                       blue:mark.c_blue
                                                      alpha:1.0] CGColor]];

    return cell;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 50.0;
}


@end
