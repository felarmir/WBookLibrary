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

#define BOOK_LIBRARY_PATH @"booklibrarypath"
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

-(BOOL)addBookToGroup:(NSString*)group bookName:(NSString*)bookName {
    BookList *book = [NSEntityDescription insertNewObjectForEntityForName:@"BookList" inManagedObjectContext:[appDelegate managedObjectContext]];
    book.bookName = bookName;
    book.groupName = group;
    
    NSError *err;
    [[book managedObjectContext] save:&err];
    if (err) {
        NSLog(@"Error to Group Add");
        return NO;
    }
    return YES;
}

//=================================================================================

-(void)setWindowSize:(CGSize)windowSize {
    [_userDefaults setFloat:windowSize.height forKey:WINDOW_HEIGHT];
    [_userDefaults setFloat:windowSize.width forKey:WINDOW_WIDTH];
}

-(CGSize)getFrameWindowSize {
    return CGSizeMake([_userDefaults floatForKey:WINDOW_WIDTH], [_userDefaults floatForKey:WINDOW_HEIGHT]);
}

-(NSArray*)bookGroups {
    return [NSArray arrayWithObjects:@"Developer", @"Languages", @"Fiction", @"Science", @"Unknown", nil];
}

@end
