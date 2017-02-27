//
//  MainViewController.m
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "MainViewController.h"
#import "BookItem.h"
#import "BookItemView.h"
#import "PDFViewer.h"
#import "DataConfigLoader.h"
#import "AppDelegate.h"

@interface MainViewController ()<DataConfigLoaderDelegate>

@end

@implementation MainViewController
{
    NSArray *bookList;
    NSString *filesDirectory;
    DataConfigLoader *dataConfig;
    AppDelegate *appDeleagte;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDeleagte = [[NSApplication sharedApplication] delegate];
    [appDeleagte.window setTitle:@"WBook Library Catalog"];
    dataConfig = [DataConfigLoader singleInstance]; // get settings object
    [dataConfig setDelegate:self];
    CGSize wsize = [dataConfig getFrameWindowSize];
    if (wsize.height == 0) {
        wsize = CGSizeMake(600, 600);
        [self.view setFrameSize:wsize];
    } else {
        [self.view setFrameSize:wsize];
    }
    
    NSNib *bookItem = [[NSNib alloc] initWithNibNamed:@"BookItem" bundle:nil];
    [_collectionView registerNib:bookItem forItemWithIdentifier:@"BookItem"];
    
    filesDirectory = [dataConfig getBookPath];
    bookList = [self readFolder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDeleagte.window];
}


-(void)resizeWindow {
    [[DataConfigLoader singleInstance] setWindowSize:self.view.frame.size];
}

-(NSString*) getFileAttributeName:(NSString*)filePath {
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    return [[pdfDoc documentAttributes] objectForKey:@"Title"];
}

-(NSArray*) readFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *fileList = (NSMutableArray*)[fileManager contentsOfDirectoryAtPath:filesDirectory error:nil];
    [fileList removeObject:@".DS_Store"];
    return fileList;
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [bookList count];
}

-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    BookItem *item = [collectionView makeItemWithIdentifier:@"BookItem" forIndexPath:indexPath];
    
    if ((indexPath.item % 2) == 0) {
        NSColor *start = [NSColor colorWithRed:153.0/255.0
                                         green:26.0/255.0 blue:61.0/255.0 alpha:1.0];
        NSColor *end = [NSColor colorWithRed:45.0/255.0
                                       green:45.0/255.0 blue:225.0/255.0 alpha:1.0];
        [(BookItemView*)item.view setStartColor:start];
        [(BookItemView*)item.view setEndColor:end];
    } else {
        NSColor *start = [NSColor colorWithRed:103.0/255.0
                                         green:36.0/255.0 blue:51.0/255.0 alpha:1.0];        
        NSColor *end = [NSColor colorWithRed:60/255.0
                                       green:60.0/255.0 blue:200.0/255.0 alpha:1.0];
        [(BookItemView*)item.view setStartColor:start];
        [(BookItemView*)item.view setEndColor:end];
    }
    
    [item.bookName setStringValue:[self getFileAttributeName:[NSString stringWithFormat:@"%@/%@", filesDirectory, [bookList objectAtIndex:indexPath.item]]]];
    
    return item;
}

-(void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSInteger item = indexPaths.anyObject.item;
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    PDFViewer *pdfv = [storyboard instantiateControllerWithIdentifier:@"PDFViewer"];
    [pdfv setBookURL:[NSString stringWithFormat:@"%@/%@", filesDirectory, [bookList objectAtIndex:item]]];
    
    appDeleagte.window.contentViewController = pdfv;
}


-(void)changeData {
    bookList = nil;
    filesDirectory = [dataConfig getBookPath];
    bookList = [self readFolder];
    [self.collectionView reloadData];
}

@end
