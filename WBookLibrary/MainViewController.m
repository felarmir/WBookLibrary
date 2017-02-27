//
//  MainViewController.m
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "MainViewController.h"
#import "BookItem.h"
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

-(NSImage*) getFirstPage:(NSString*)filePath {
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    NSPDFImageRep *pdfImg = [NSPDFImageRep imageRepWithData:pdfData];
    [pdfImg setCurrentPage:0];
    NSImage *fpageImage = [[NSImage alloc] init];
    [fpageImage addRepresentation:pdfImg];
    
    NSImage *smallImage = [[NSImage alloc]initWithSize:NSMakeSize(130, 170)];
    NSSize originalSize = [fpageImage size];
    NSRect fromRect = NSMakeRect(0, 0, originalSize.width, originalSize.height);
    [smallImage lockFocus];
    [fpageImage drawInRect:NSMakeRect(0, 0, 130, 170) fromRect:fromRect operation:NSCompositingOperationCopy fraction:1.0f];
    [smallImage unlockFocus];
    
    
    return smallImage;
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
    [item.bookCover setImage:[self getFirstPage:[NSString stringWithFormat:@"%@/%@", filesDirectory, [bookList objectAtIndex:indexPath.item]]]];
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
