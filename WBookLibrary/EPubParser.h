//
//  EPubParser.h
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPubParserDeleage <NSObject>

-(void)parseFinish:(NSDictionary*)epubDataInfo;

@end

@interface EPubParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) id<EPubParserDeleage> delegate;

-(void)epubFileLoader:(NSString*)filePath destination:(NSString*)destinationPath;

@end
