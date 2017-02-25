//
//  DataConfigLoader.h
//  WBookLibrary
//
//  Created by Denis Andreev on 25/02/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataConfigLoaderDelegate <NSObject>

-(void)changeData;

@end

@interface DataConfigLoader : NSObject

@property (nonatomic, assign) id<DataConfigLoaderDelegate> delegate;
@property (nonatomic) NSUserDefaults *userDefaults;

+(DataConfigLoader*) singleInstance;

-(NSString*)getBookPath;
-(void)setBookPath:(NSString*)path;

@end
