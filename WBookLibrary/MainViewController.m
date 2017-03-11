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
#import "EPubViewController.h"
#import "DataConfigLoader.h"
#import "AppDelegate.h"
#import "LibraryViewWithDragAndDrop.h"
#import "CollectionViewSectionHeader.h"
#import "BookList+CoreDataClass.h"

@interface MainViewController ()<DataConfigLoaderDelegate, LibraryViewWithDragAndDropDelegate>

@end

@implementation MainViewController
{
    NSString *filesDirectory;
    DataConfigLoader *dataConfig;
    AppDelegate *appDeleagte;
    BOOL isEditBookList;
    
    NSMutableDictionary<NSString*, NSArray*> *bookListDict;
    NSMutableDictionary<NSString*, NSString*> *fileNameRealName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDeleagte = [[NSApplication sharedApplication] delegate];
    appDeleagte.window.titlebarAppearsTransparent = YES;
    appDeleagte.window.toolbar = nil;
    [_collectionView setDelegate:self];
    dataConfig = [DataConfigLoader singleInstance]; // get settings object
    [dataConfig setDelegate:self];
    [(LibraryViewWithDragAndDrop*)self.view setDelegate:self];
    
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
    
    [self generateBookListArrayByGroup];
    
    isEditBookList = NO;
    
    [self.view setWantsLayer:YES];
    self.view.layer.cornerRadius = 5.0;
    [self.view.layer setBackgroundColor:[NSColor blackColor].CGColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDeleagte.window];
}

-(void)resizeWindow {
    [[DataConfigLoader singleInstance] setWindowSize:self.view.frame.size];
}
/**
 Book list by group
 */
-(void)generateBookListArrayByGroup {
    //[0"Developer", 1"Languages", 2"Fiction", 3"Science", 4"Unknown"];
    NSArray *groupList = [[DataConfigLoader singleInstance] bookGroups];
    NSArray *booksInDB = [[DataConfigLoader singleInstance] loadBookGroupList];
    NSArray *bookList = [self readFolder];
    fileNameRealName = [[NSMutableDictionary alloc] init];
    bookListDict = [[NSMutableDictionary alloc] init];
    
    if ([booksInDB count] == 0) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [bookList count]; i++) {
            [tmpArray addObject:[self bookNameByIndex:bookList index:i]];
            [fileNameRealName setObject:[bookList objectAtIndex:i] forKey:[self bookNameByIndex:bookList index:i]];
        }
        [bookListDict setObject:tmpArray forKey:[groupList lastObject]];
    } else {
        
        
    }
}

-(NSString*)bookNameByIndex:(NSArray*)books index:(NSInteger)index {
    NSString *tmp = [self getFileAttributeName:[NSString stringWithFormat:@"%@/%@", filesDirectory, [books objectAtIndex:index]]];
    
    if (tmp == nil) {
        tmp = [books objectAtIndex:index];
    }
    return tmp;
}

-(NSString*) getFileAttributeName:(NSString*)filePath {
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    return [[pdfDoc documentAttributes] objectForKey:@"Title"];
}

-(NSArray*) readFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *fileList = (NSMutableArray*)[fileManager contentsOfDirectoryAtPath:filesDirectory error:nil];
    NSPredicate *pdfPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pdf'"];
    NSPredicate *epubPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.epub'"];
    
    NSMutableArray *ff = [[NSMutableArray alloc] init];
    [ff addObjectsFromArray:[fileList filteredArrayUsingPredicate:pdfPredicate]];
    [ff addObjectsFromArray:[fileList filteredArrayUsingPredicate:epubPredicate]];
    return ff;
}

// Collection View start

-(NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return [[bookListDict allKeys] count];
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[bookListDict objectForKey:[[bookListDict allKeys] objectAtIndex:section]] count];
}

-(NSView*)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CollectionViewSectionHeader *header = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"CollectionViewSectionHeader" forIndexPath:indexPath];
    if ([kind isEqualToString:NSCollectionElementKindSectionHeader]) {
        [header.headerText setStringValue:[[bookListDict allKeys] objectAtIndex:indexPath.section]];
    }
    return header;
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
    
    [item setBookEditMode:isEditBookList];
    
    [item.bookName setStringValue:[[bookListDict objectForKey:[[bookListDict allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.item]];
    
    return item;
}

-(void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSInteger item = indexPaths.anyObject.item;
    if (!isEditBookList) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSArray *bookArray = [bookListDict objectForKey:[[bookListDict allKeys] objectAtIndex:indexPaths.anyObject.section]];
        NSString *fileName = [fileNameRealName objectForKey:[bookArray objectAtIndex:item]];
        if ([[fileName pathExtension] isEqualToString:@"pdf"]) {
            PDFViewer *pdfv = [storyboard instantiateControllerWithIdentifier:@"PDFViewer"];
            [pdfv setBookURL:[NSString stringWithFormat:@"%@%@", filesDirectory, fileName]];
            [appDeleagte.window setContentViewController:pdfv];
        } else if([[fileName pathExtension] isEqualToString:@"epub"]) {
            EPubViewController *epubvc = [storyboard instantiateControllerWithIdentifier:@"EPubViewController"];
            [epubvc setBookPath:[NSString stringWithFormat:@"%@/%@", filesDirectory, fileName]];
            [appDeleagte.window setContentViewController:epubvc];
        }
    }
    
}

// collection view end

-(void)finishBookLoad {
    [self changeData];
    [_progressView setHidden:YES];
}

-(void)copyProgressStatus:(NSNumber*)progress {
    [_progressView setHidden:NO];
    _progressView.progressIndicator.doubleValue = [progress floatValue];
}

-(void)changeData {
    [self generateBookListArrayByGroup];
    [self.collectionView reloadData];
}

-(IBAction)editBookList:(id)sender {
    if (isEditBookList) {
        [_editButton setTitle:@"Edit"];
        [_editButton.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [_editButton setTitle:@"Editing"];
        [_editButton.layer setBackgroundColor:[NSColor grayColor].CGColor];
        [_editButton.layer setCornerRadius:5.0];
    }
    [_collectionView reloadData];
    isEditBookList = !isEditBookList;
}


@end
