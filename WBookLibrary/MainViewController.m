//
//  MainViewController.m
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "MainViewController.h"
#import "BookItem.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSArray *bookList;
    NSString *filesDirectory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNib *bookItem = [[NSNib alloc] initWithNibNamed:@"BookItem" bundle:nil];
    [_collectionView registerNib:bookItem forItemWithIdentifier:@"BookItem"];
    
    filesDirectory = @"/Volumes/DartDionis/Books/Objective-C";
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

@end
