//
//  DataConfigLoader.m
//  WBookLibrary
//
//  Created by Denis Andreev on 25/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "DataConfigLoader.h"
#import "AppDelegate.h"
#import "BookList+CoreDataProperties.h"
#import "AppSettings+CoreDataProperties.h"
#import "PagePositin+CoreDataProperties.h"


#define WINDOW_HEIGHT @"windowheight"
#define WINDOW_WIDTH @"windowwidth"


@implementation DataConfigLoader
{
    AppDelegate *appDelegate;
}

+(DataConfigLoader*) singleInstance {
    static DataConfigLoader *configInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configInstance = [[self alloc] init];
    });
    return configInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDefults];
    }
    return self;
}

-(void) createDefults {
    appDelegate = [[NSApplication sharedApplication] delegate];
    _userDefaults = [[NSUserDefaults alloc] init];
}

-(NSString*)getBookPath {
    if ([self loadSettingsData].count == 0) {
        NSString *path = [[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents"] stringByAppendingString:@"/WBoolLib"];
        [self addPathToSettings:path];
        return path;
    }
    
    return [(AppSettings*)[[self loadSettingsData] objectAtIndex:0] bookLibPath];
}


-(void)setBookPath:(NSString*)path {
    AppSettings *settings= (AppSettings*)[[self loadSettingsData] objectAtIndex:0];
    settings.bookLibPath = path;
    NSError *error;
    [settings.managedObjectContext save:&error];
    if(error) {
        NSLog(@"Error update data");
    } else {
        if(_delegate && [_delegate respondsToSelector:@selector(changeData)]) {
            [_delegate performSelector:@selector(changeData)];
        }
    }
}

-(NSArray*)loadSettingsData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"AppSettings" inManagedObjectContext:[appDelegate managedObjectContext]];
    NSError *error;
    NSArray *data = [[appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error load data!");
        return nil;
    }
    return data;
}

-(void)addPathToSettings:(NSString*)path {
    AppSettings *settings = [NSEntityDescription insertNewObjectForEntityForName:@"AppSettings" inManagedObjectContext:[appDelegate managedObjectContext]];
    settings.bookLibPath = path;
    NSError *error;
    [[settings managedObjectContext] save:&error];
    if (error) {
        NSLog(@"Error to save");
    }
}

-(NSArray*)loadBookGroupList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"BookList" inManagedObjectContext:[appDelegate managedObjectContext]];
    NSError *err;
    NSArray *data = [[appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&err];
    if(err) {
        NSLog(@"Error load data");
        return nil;
    }
    return data;
}


/**
 Function for adding book to group

 @param group NSString value which contains Group name
 @param bookName NSString value book name
 @return result success add or not
 */
-(BOOL)addBookToGroup:(NSString*)group bookName:(NSString*)bookName {
    
    BookList *book = nil;
    
    if ((book = [self chekBookInGroups:bookName]) != nil) {
        book.groupName = group;
        NSError *err;
        [[book managedObjectContext] save:&err];
        if (err) {
            NSLog(@"Error update");
            return NO;
        }
    } else {
        book = [NSEntityDescription insertNewObjectForEntityForName:@"BookList" inManagedObjectContext:[appDelegate managedObjectContext]];
        book.bookName = bookName;
        book.groupName = group;
    
        NSError *err;
        [[book managedObjectContext] save:&err];
        if (err) {
            NSLog(@"Error to Group Add");
            return NO;
        }
    }
    return YES;
}

-(BookList*)chekBookInGroups:(NSString*)bookName {
    NSArray *tmpArray = [self loadBookGroupList];
    for (int i = 0; i < [tmpArray count]; i++) {
        BookList *tmpBook = [tmpArray objectAtIndex:i];
        if ([tmpBook.bookName isEqualToString:bookName]) {
            return tmpBook;
        }
    }
    
    return nil;
}

-(NSArray*)loadPagesPosition {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"PagePositin" inManagedObjectContext:[appDelegate managedObjectContext]];
    NSError *error;
    NSArray *data = [[appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"Error get data");
        return nil;
    }
    return data;
}

-(BOOL)addPagePositinByName:(NSString*)bookName page:(int)page {
    PagePositin *pp = nil;
    if ((pp = [self checkBookPagePositin:bookName]) != nil) {
        pp.pagePosition = page;
        NSError *err;
        [[pp managedObjectContext] save:&err];
        if(err) {
            return NO;
        }
    } else {
        pp = [NSEntityDescription insertNewObjectForEntityForName:@"PagePositin" inManagedObjectContext:[appDelegate managedObjectContext]];
        pp.bookName = bookName;
        pp.pagePosition = page;
        
        NSError *err;
        [[pp managedObjectContext] save:&err];
        if(err) {
            return NO;
        }
    }
    
    return YES;
}

-(PagePositin*)checkBookPagePositin:(NSString*)bookName {
    NSArray *tmp = [self loadPagesPosition];
    for(int i = 0; i < [tmp count]; i++) {
        PagePositin *pp = [tmp objectAtIndex:i];
        if([bookName isEqualToString:[pp bookName]]) {
            return pp;
        }
    }
    return nil;
}

-(int)getPagePositin:(NSString*)bookName {
    return [[self checkBookPagePositin:bookName] pagePosition];
}

//=================================================================================

-(void)setWindowSize:(CGSize)windowSize {
    [_userDefaults setFloat:windowSize.height forKey:WINDOW_HEIGHT];
    [_userDefaults setFloat:windowSize.width forKey:WINDOW_WIDTH];
}

-(CGSize)getFrameWindowSize {
    return CGSizeMake([_userDefaults floatForKey:WINDOW_WIDTH], [_userDefaults floatForKey:WINDOW_HEIGHT]);
}


/**
 Book Groups constants

 @return NSArray with groups
 */
-(NSArray*)bookGroups {
    return [NSArray arrayWithObjects:@"Developer", @"Languages", @"Fiction", @"Science", nil];
}

@end
