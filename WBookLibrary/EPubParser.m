//
//  EPubParser.m
//  WBookLibrary
//
//  Created by Wiirlock on 01.03.17.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "EPubParser.h"
#import "SSZipArchive.h"

@implementation EPubParser 
{
    NSXMLParser *xmlPareser;
    NSMutableDictionary *epubDataInfo;
    NSString *filesPath;
    BOOL isMetaParse;
}



-(void)epubFileLoader:(NSString*)filePath destination:(NSString*)destinationPath {
    [SSZipArchive unzipFileAtPath:filePath toDestination:destinationPath];
     NSString *metaPath = [NSString stringWithFormat:@"%@/%@", destinationPath, @"META-INF/container.xml"];
    isMetaParse = false;
    filesPath = destinationPath;
    [self parseMetaInf:metaPath];
}

-(void)parseMetaInf:(NSString*)path {
    xmlPareser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
    [xmlPareser setDelegate:self];
    [xmlPareser parse];
}

-(void)parseOPF:(NSString*)opfPath {
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        NSXMLParser *opfParser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:opfPath]];
        [opfParser setDelegate:self];
        [opfParser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{ });
    
    
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
     NSLog(@"Parse");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if(!isMetaParse) {
        if ([elementName isEqualToString:@"rootfile"]) {
            [self parseOPF:[NSString stringWithFormat:@"%@/%@", filesPath, [attributeDict objectForKey:@"full-path"]]];
            isMetaParse = true;
            [xmlPareser abortParsing];
        }
    } else {
        NSLog(@"%@", attributeDict);
    }
}


@end
