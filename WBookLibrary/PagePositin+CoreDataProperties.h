//
//  PagePositin+CoreDataProperties.h
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "PagePositin+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PagePositin (CoreDataProperties)

+ (NSFetchRequest<PagePositin *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookName;
@property (nonatomic) int32_t pagePosition;

@end

NS_ASSUME_NONNULL_END
