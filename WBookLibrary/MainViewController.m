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

@interface MainViewController ()<DataConfigLoaderDelegate, LibraryViewWithDragAndDropDelegate, BookItemDelegate>

@end

@implementation MainViewController
{
    /** 
        for keep book files directory
     */
    NSString *filesDirectory;
    DataConfigLoader *dataConfig;
    AppDelegate *appDeleagte;
    BOOL isEditBookList;
    
    /**
        Dictionary for keep data by group
     */
    NSMutableDictionary<NSString*, NSArray*> *bookListDict;
    
    /**
        Dictionary for relation between file name and atribute name
     */
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
    [_collectionView.layer setBorderColor:[NSColor clearColor].CGColor];
    [_editButton.layer setBackgroundColor:[NSColor clearColor].CGColor];
    
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
    [self.view.layer setBackgroundColor:[NSColor clearColor].CGColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeWindow) name:NSWindowDidResizeNotification object:appDeleagte.window];
}

/**
    function for save findow size after resize
 */
-(void)resizeWindow {
    [[DataConfigLoader singleInstance] setWindowSize:self.view.frame.size];
}

/**
    Generate books by group
 */
-(void)generateBookListArrayByGroup {
    
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
        [bookListDict setObject:tmpArray forKey:@"Unknown"];
    } else {
        for (int i = 0; i < [bookList count]; i++) {
            NSString *tmpGr = [self getBookGroup:booksInDB bookName:[self bookNameByIndex:bookList index:i]];
            if (tmpGr != nil) {
                if([bookListDict objectForKey:tmpGr] == nil) {
                    [bookListDict setObject:[NSMutableArray arrayWithObject:[self bookNameByIndex:bookList index:i]] forKey:tmpGr];
                } else {
                    [(NSMutableArray*)[bookListDict objectForKey:tmpGr] addObject:[self bookNameByIndex:bookList index:i]];
                }
            } else {
                if ([bookListDict objectForKey:@"Unknown"] == nil) {
                    [bookListDict setObject:[NSMutableArray arrayWithObject:[self bookNameByIndex:bookList index:i]] forKey:@"Unknown"];
                } else {
                    [(NSMutableArray*)[bookListDict objectForKey:@"Unknown"] addObject:[self bookNameByIndex:bookList index:i]];
                }
            }
        [fileNameRealName setObject:[bookList objectAtIndex:i] forKey:[self bookNameByIndex:bookList index:i]];
        }
        
    }
}

/**
    function for check that book contains group or not 
*/
-(NSString*)getBookGroup:(NSArray<BookList*>*)bookArray bookName:(NSString*)bookName {
    for (int i = 0; i < [bookArray count]; i++) {
        BookList *book = (BookList*)[bookArray objectAtIndex:i];
        if ([bookName isEqualToString:[book bookName]]) {
            return [book groupName];
        }
    }
    return nil;
}

/**
    function will return book name from attribute or if atribute does not contain book name then return file name
 */
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

/**
    function for reading files directory and return epub and pdf files array
 */
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

#pragma mark - NSCollectionView delegate methods

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
    [item setDelegate:self];
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
    [item.groupBox setStringValue:[[bookListDict allKeys] objectAtIndex:indexPath.section]];
    
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

-(void)finishSaveToGroup {
    [self generateBookListArrayByGroup];
    [self.collectionView reloadData];
}

-(void)copyProgressStatus:(NSNumber*)progress {
    [_progressView setHidden:NO];
    _progressView.progressIndicator.doubleValue = [progress floatValue];
}

-(void)changeData {
    [self generateBookListArrayByGroup];
    [self.collectionView reloadData];
}

#pragma mark - IBAction for edit collection view  

-(IBAction)editBookList:(id)sender {
    if (isEditBookList) {
        [_editButton setTitle:@"Edit"];
    } else {
        [_editButton setTitle:@"Editing"];
        [_editButton.layer setCornerRadius:5.0];
    }
    
    NSColor *color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[_editButton attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [_editButton setAttributedTitle:colorTitle];
    
    [_collectionView reloadData];
    isEditBookList = !isEditBookList;
}


@end
