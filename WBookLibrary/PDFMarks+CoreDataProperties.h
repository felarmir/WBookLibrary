//
//  PDFMarks+CoreDataProperties.h
//  WBookLibrary
//
//  Created by Denis Andreev on 02/04/2017.
//  Copyright © 2017 Denis Andreev. All rights reserved.
//

#import "PDFMarks+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PDFMarks (CoreDataProperties)

+ (NSFetchRequest<PDFMarks *> *)fetchRequest;

@property (nonatomic) int32_t page;
@property (nullable, nonatomic, copy) NSString *bookName;
@property (nullable, nonatomic, copy) NSString *text;
@property (nonatomic) float c_red;
@property (nonatomic) float c_blue;
@property (nonatomic) float c_green;

@end

NS_ASSUME_NONNULL_END
