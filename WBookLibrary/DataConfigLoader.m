//
//  DataConfigLoader.m
//  WBookLibrary
//
//  Created by Denis Andreev on 25/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "DataConfigLoader.h"

#define BOOK_LIBRARY_PATH @"booklibrarypath"


@implementation DataConfigLoader

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
    _userDefaults = [[NSUserDefaults alloc] init];
 //   NSString *bookPath = [_userDefaults stringForKey:BOOK_LIBRARY_PATH];
}

-(NSString*)getBookPath {
    if ([_userDefaults stringForKey:BOOK_LIBRARY_PATH] == nil) {
        return [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents"];
    }

    return [_userDefaults stringForKey:BOOK_LIBRARY_PATH];
}

-(void)setBookPath:(NSString*)path {
    [_userDefaults setValue:path forKey:BOOK_LIBRARY_PATH];
    if(_delegate && [_delegate respondsToSelector:@selector(changeData)]) {
        [_delegate performSelector:@selector(changeData)];
    }
}



@end
