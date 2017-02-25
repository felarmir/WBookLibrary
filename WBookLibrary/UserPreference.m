//
//  UserPreference.m
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "UserPreference.h"
#import "DataConfigLoader.h"

@interface UserPreference ()

@end

@implementation UserPreference

- (void)viewDidLoad {
    [super viewDidLoad];
    _pathField.stringValue = [[DataConfigLoader singleInstance] getBookPath];
}

-(IBAction)selectFolder:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel runModal];
    
    NSString *path = [[[panel URLs] lastObject].absoluteString substringFromIndex:7];
    _pathField.stringValue = path;
    [[DataConfigLoader singleInstance] setBookPath:path];
}

@end
