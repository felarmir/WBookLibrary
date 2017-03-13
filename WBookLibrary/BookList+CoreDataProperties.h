//
//  BookList+CoreDataProperties.h
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "BookList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BookList (CoreDataProperties)

+ (NSFetchRequest<BookList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookName;
@property (nullable, nonatomic, copy) NSString *groupName;

@end

NS_ASSUME_NONNULL_END
