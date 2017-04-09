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
    NSString *dstFile;
    NSTimer *timer;
    int curFileSize;
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
    NSArray *extensions = @[@"pdf"];
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
    for(NSString *curFile in dragFile) {
        dstFile = [NSString stringWithFormat:@"%@/%@", [[DataConfigLoader singleInstance] getBookPath], [curFile lastPathComponent]];
        curFileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:curFile error:nil] objectForKey:@"NSFileSize"] intValue];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(checkFile) userInfo:nil repeats:YES];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:curFile]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSFileManager defaultManager] copyItemAtPath:curFile toPath:dstFile error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_delegate && [_delegate respondsToSelector:@selector(finishBookLoad)]) {
                        [_delegate performSelector:@selector(finishBookLoad)];
                        [timer invalidate];
                        timer = nil;
                        dstFile = nil;
                    }
                });
            });
        }
    }
    
}

-(void)checkFile {
    int fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:dstFile error:nil] objectForKey:@"NSFileSize"] intValue];
    if (_delegate && [_delegate respondsToSelector:@selector(copyProgressStatus:)]) {
        [_delegate performSelector:@selector(copyProgressStatus:) withObject:[NSNumber numberWithFloat:((float)fileSize/(float)curFileSize)]];
    }

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    self.layer.borderColor = [NSColor blackColor].CGColor;
    [NSBezierPath strokeRect:[self bounds]];
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}


@end
