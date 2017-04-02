//
//  PDFMarks+CoreDataProperties.m
//  WBookLibrary
//
//  Created by Denis Andreev on 02/04/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "PDFMarks+CoreDataProperties.h"

@implementation PDFMarks (CoreDataProperties)

+ (NSFetchRequest<PDFMarks *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PDFMarks"];
}

@dynamic page;
@dynamic bookName;
@dynamic text;
@dynamic c_red;
@dynamic c_blue;
@dynamic c_green;

@end
