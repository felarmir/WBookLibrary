//
//  AppSettings+CoreDataProperties.h
//  WBookLibrary
//
//  Created by Wiirlock on 13.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "AppSettings+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AppSettings (CoreDataProperties)

+ (NSFetchRequest<AppSettings *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookLibPath;

@end

NS_ASSUME_NONNULL_END
