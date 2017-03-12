//
//  BookItem.h
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BookItemDelegate <NSObject>

-(void)finishSaveToGroup;

@end

@interface BookItem : NSCollectionViewItem <NSComboBoxDelegate, NSComboBoxDataSource>

@property (nonatomic, assign) id<BookItemDelegate> delegate;

@property (weak) IBOutlet NSTextField *bookName;
@property (weak) IBOutlet NSComboBox *groupBox;
@property (nonatomic) NSString *groupName;

-(void)setBookEditMode:(BOOL)isEdit;

@end
