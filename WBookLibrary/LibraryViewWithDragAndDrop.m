//
//  LibraryViewWithDragAndDrop.m
//  WBookLibrary
//
//  Created by Denis Andreev on 05/03/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "LibraryViewWithDragAndDrop.h"
#import "DataConfigLoader.h"

@implementation LibraryViewWithDragAndDrop
{
    BOOL highlight;
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    highlight = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationGeneric;
}

-(void)draggingExited:(id<NSDraggingInfo>)sender {
    highlight = NO;
    [self setNeedsDisplay:YES];
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    highlight = NO;
    [self setNeedsDisplay:YES];
    return YES;
}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSArray *extensions = @[@"epub", @"pdf"];
    NSArray *dragFileName = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([extensions containsObject:[[dragFileName objectAtIndex:0] pathExtension]]) {
        return YES;
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Unsupport File!"];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return NO;
    }
}

-(void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    NSArray *dragFile = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSString *fileName = [dragFile objectAtIndex:0];

    if ([[NSFileManager defaultManager] isReadableFileAtPath:fileName]) {
        [[NSFileManager defaultManager] copyItemAtPath:fileName toPath:[NSString stringWithFormat:@"%@/%@", [[DataConfigLoader singleInstance] getBookPath], [fileName lastPathComponent]] error:nil];
        if (_delegate && [_delegate respondsToSelector:@selector(finishBookLoad)]) {
            [_delegate performSelector:@selector(finishBookLoad)];
        }
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    if (highlight) {
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth:5.0];
        [NSBezierPath strokeRect:[self bounds]];
    }
}

@end
