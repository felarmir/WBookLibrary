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

@interface MainViewController ()<DataConfigLoaderDelegate>

@end

@implementation MainViewController
{
    NSArray *bookList;
    NSString *filesDirectory;
    DataConfigLoader *dataConfig;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataConfig = [DataConfigLoader singleInstance]; // get settings object
    [[DataConfigLoader singleInstance] setDelegate:self];
    NSNib *bookItem = [[NSNib alloc] initWithNibNamed:@"BookItem" bundle:nil];
    [_collectionView registerNib:bookItem forItemWithIdentifier:@"BookItem"];
    
    filesDirectory = [dataConfig getBookPath];
    bookList = [self readFolder];
    
}

-(NSImage*) getFirstPage:(NSString*)filePath {
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    NSPDFImageRep *pdfImg = [NSPDFImageRep imageRepWithData:pdfData];
    [pdfImg setCurrentPage:0];
    NSImage *fpageImage = [[NSImage alloc] init];
    [fpageImage addRepresentation:pdfImg];
    return fpageImage;
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
    [self presentViewControllerAsModalWindow:pdfv];
}

-(void)changeData {
    bookList = nil;
    filesDirectory = [dataConfig getBookPath];
    bookList = [self readFolder];
    [self.collectionView reloadData];
}

@end
