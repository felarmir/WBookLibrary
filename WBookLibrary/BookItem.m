//
//  BookItem.m
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "BookItem.h"
#import "DataConfigLoader.h"

@interface BookItem ()

@end

@implementation BookItem
{
    NSArray *groupArray;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
      if(selected) {
        [self.view.layer setShadowColor:[NSColor blueColor].CGColor];
        [self.view.layer setShadowOpacity:0.5];
        [self.view.layer setShadowRadius:10.0];
        [self.view setNeedsDisplay:YES];
    } else {
        [self.view.layer setShadowOpacity:0.0];
    }
    
    groupArray = [[DataConfigLoader singleInstance] bookGroups];
    [_groupBox setDataSource:self];
    [_groupBox setDelegate:self];
    [_groupBox setUsesDataSource:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setBookEditMode:(BOOL)isEdit {
    [_groupBox setHidden:!isEdit];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return groupArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if(index!=-1)
        return [groupArray objectAtIndex:index];
    else
        return nil;
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification {
    [[DataConfigLoader singleInstance] addBookToGroup:[groupArray objectAtIndex:[_groupBox indexOfSelectedItem]] bookName:[_bookName stringValue]];
}

@end
