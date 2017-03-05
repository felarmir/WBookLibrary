//
//  LibraryViewWithDragAndDrop.h
//  WBookLibrary
//
//  Created by Denis Andreev on 05/03/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LibraryViewWithDragAndDropDelegate <NSObject>

-(void)finishBookLoad;
-(void)copyProgressStatus:(NSNumber*)progress;

@end

@interface LibraryViewWithDragAndDrop : NSView <NSFileManagerDelegate>

@property (nonatomic, assign) id<LibraryViewWithDragAndDropDelegate> delegate;

@end
