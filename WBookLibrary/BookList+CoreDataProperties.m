//
//  BookList+CoreDataProperties.m
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "BookList+CoreDataProperties.h"

@implementation BookList (CoreDataProperties)

+ (NSFetchRequest<BookList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BookList"];
}

@dynamic bookName;
@dynamic groupName;

@end
