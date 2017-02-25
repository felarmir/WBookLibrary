//
//  UserPreference.h
//  WBookLibrary
//
//  Created by Denis Andreev on 24/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UserPreference : NSViewController

@property (weak) IBOutlet NSTextField *pathField;

-(IBAction)selectFolder:(id)sender;

@end
