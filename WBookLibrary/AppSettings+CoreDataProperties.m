//
//  AppSettings+CoreDataProperties.m
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "AppSettings+CoreDataProperties.h"

@implementation AppSettings (CoreDataProperties)

+ (NSFetchRequest<AppSettings *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AppSettings"];
}

@dynamic bookLibPath;

@end
