//
//  UILabel+WBExtensions.m
//  NoticeView
//
//  Created by Tito Ciuro on 5/15/12.
//  Copyright (c) 2012 Tito Ciuro. All rights reserved.
//

#import "UILabel+WBExtensions.h"

@implementation UILabel (WBExtensions)

- (NSArray *)splitLinesOfText:(NSString *)text constrainingToSizeWithFont:(UIFont *)font maximumWidth:(CGFloat)maximumWidth
{
    NSArray *splitText = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:[splitText count]];
    if ([splitText count] > 1) {
        [splitText enumerateObjectsUsingBlock:^(NSString *subText, NSUInteger idx, BOOL *stop) {
            [lines addObjectsFromArray:[self splitLinesOfText:subText constrainingToSizeWithFont:font maximumWidth:maximumWidth]];
        }];
    } else {
        NSCharacterSet *wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *currentLine = text;
        int textLength = [text length];
        
        NSRange rCurrentLine = NSMakeRange(0, textLength);
        NSRange rWhitespace = NSMakeRange(0, 0);
        NSRange rRemainingText = NSMakeRange(0, textLength);
        BOOL done = NO;
        
        while (NO == done) {
            // determine the next whitespace word separator position
            rWhitespace.location = rWhitespace.location + rWhitespace.length;
            rWhitespace.length = textLength - rWhitespace.location;
            rWhitespace = [text rangeOfCharacterFromSet:wordSeparators options:NSCaseInsensitiveSearch range:rWhitespace];
            
            if (NSNotFound == rWhitespace.location) {
                rWhitespace.location = textLength;
                done = YES;
            }
            
            NSRange rTest = NSMakeRange(rRemainingText.location, rWhitespace.location - rRemainingText.location);
            NSString *textTest = [text substringWithRange:rTest];
            CGSize sizeTest = [textTest sizeWithFont:font forWidth:1024.0 lineBreakMode:NSLineBreakByWordWrapping];
            
            if (sizeTest.width > maximumWidth) {
                [lines addObject:[currentLine stringByTrimmingCharactersInSet:wordSeparators]];
                rRemainingText.location = rCurrentLine.location + rCurrentLine.length;
                rRemainingText.length = textLength-rRemainingText.location;
                continue;
            }
            
            rCurrentLine = rTest;
            currentLine = textTest;
        }
        
        [lines addObject:[currentLine stringByTrimmingCharactersInSet:wordSeparators]];
    }
    
    return lines;
}

- (NSArray *)lines
{
    if (! [self.text length]) return nil;
    return [self splitLinesOfText:self.text constrainingToSizeWithFont:self.font maximumWidth:self.bounds.size.width];
}

@end