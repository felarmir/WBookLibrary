//
//  EPubViewController.h
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface EPubViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *epubContentView;

@property (nonatomic) NSString *bookPath;

@end
