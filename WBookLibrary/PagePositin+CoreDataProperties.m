//
//  PagePositin+CoreDataProperties.m
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "PagePositin+CoreDataProperties.h"

@implementation PagePositin (CoreDataProperties)

+ (NSFetchRequest<PagePositin *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PagePositin"];
}

@dynamic bookName;
@dynamic pagePosition;

@end
