//
//  MainViewController.h
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressView.h"

@interface MainViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet ProgressView *progressView;
@property (weak) IBOutlet NSButton *editButton;

-(IBAction)editBookList:(id)sender;

@end
