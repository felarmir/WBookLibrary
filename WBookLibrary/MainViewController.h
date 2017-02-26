//
//  MainViewController.h
//  WBookLibrary
//
//  Created by Denis Andreev on 20/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;


@end
