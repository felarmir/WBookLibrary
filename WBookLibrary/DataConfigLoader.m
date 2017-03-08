//
//  DataConfigLoader.m
//  WBookLibrary
//
//  Created by Denis Andreev on 25/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "DataConfigLoader.h"

#define BOOK_LIBRARY_PATH @"booklibrarypath"
#define WINDOW_HEIGHT @"windowheight"
#define WINDOW_WIDTH @"windowwidth"


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

-(void)setWindowSize:(CGSize)windowSize {
    [_userDefaults setFloat:windowSize.height forKey:WINDOW_HEIGHT];
    [_userDefaults setFloat:windowSize.width forKey:WINDOW_WIDTH];
}

-(CGSize)getFrameWindowSize {
    return CGSizeMake([_userDefaults floatForKey:WINDOW_WIDTH], [_userDefaults floatForKey:WINDOW_HEIGHT]);
}

@end
