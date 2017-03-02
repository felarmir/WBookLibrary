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
    NSString *opfFilePath;
    
    BOOL isMetaParse;
    BOOL isStartParseOPF;
    BOOL isStartParsingSpine;
    BOOL isStartManifest;
    BOOL isManifestItems;
    BOOL isFinishParseDocument;
}



-(void)epubFileLoader:(NSString*)filePath destination:(NSString*)destinationPath {
    [SSZipArchive unzipFileAtPath:filePath toDestination:destinationPath];
     NSString *metaPath = [NSString stringWithFormat:@"%@/%@", destinationPath, @"META-INF/container.xml"];
    epubDataInfo = [[NSMutableDictionary alloc] init];
    
    isMetaParse = false;
    isStartParseOPF = false;
    isManifestItems = false;
    isStartManifest = false;
    isFinishParseDocument = false;
    
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
        isMetaParse = true;
        [opfParser parse];
    });

}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if(!isMetaParse) {
        if ([elementName isEqualToString:@"rootfile"]) {
            opfFilePath = [NSString stringWithFormat:@"%@/%@", filesPath, [attributeDict objectForKey:@"full-path"]];
                isMetaParse = true;
        }
    }
    
    if (isStartManifest) {
        if ([elementName isEqualToString:@"manifest"]) {
            isManifestItems = true;
            [epubDataInfo setObject:[[NSMutableDictionary alloc] init] forKey:@"manifest"];
        }
        if (isManifestItems) {
            if ([elementName isEqualToString:@"item"]) {
                [[epubDataInfo objectForKey:@"manifest"] setValue:[NSString stringWithFormat:@"%@/%@",opfFilePath,[attributeDict objectForKey:@"href"]] forKey:[attributeDict objectForKey:@"id"]];
            }
        }
    }
    
    if(isStartParseOPF){
        if ([elementName isEqualToString:@"spine"]) {
            isStartParsingSpine = true;
            [epubDataInfo setObject:[[NSMutableArray alloc] init] forKey:@"spine"];
        }
        if(isStartParsingSpine) {
            if ([elementName isEqualToString:@"itemref"]) {
                [[epubDataInfo objectForKey:@"spine"] addObject:[attributeDict objectForKey:@"idref"]];
            }
        }
        
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"spine"]) {
        isStartParsingSpine = false;
    }
    if([elementName isEqualToString:@"manifest"]) {
        isManifestItems = false;
    }
    if([elementName isEqualToString:@"package"]) {
        isFinishParseDocument = true;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (!isStartParseOPF) {
        isStartManifest = true;
        isStartParseOPF = true;
        [self parseOPF:opfFilePath];
    }
    if (isFinishParseDocument) {
        if (_delegate && [_delegate respondsToSelector:@selector(parseFinish:)]) {
            [_delegate performSelector:@selector(parseFinish:) withObject:epubDataInfo];
        }
    }
}


@end
