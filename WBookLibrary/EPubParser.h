//
//  EPubParser.h
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPubParser : NSObject <NSXMLParserDelegate>

-(void)epubFileLoader:(NSString*)filePath destination:(NSString*)destinationPath;

@end
