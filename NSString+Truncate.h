#import <Cocoa/Cocoa.h>


@interface NSString (Truncate) 

/*!
 @brief    Truncates a string to a given limit of characters, max,
 by replacing words or characters about 2/3 of the way through with
 an ellipsis if the receiver exceeds the limit

 @details  If the receiver does not exceed the limit, returns self
 @param    limit  The maximum number of characters allowed
 @param    wholeWords  YES to try and truncate the string by removing
 only whole words.  This will generally result in a string which 
 has a length somewhat less than the given limit.  If you pass YES
 and the given limit cannot be achieved by removing words, which is
 generally because it contains a word which is longer than the limit
 all by itself, characters are truncated instead.
*/
- (NSString*)stringByTruncatingMiddleToLength:(int)limit
								   wholeWords:(BOOL)wholeWords ;

- (NSAttributedString *)attributedStringWithTruncationStyle:(int)truncationStyle ;

@end

#if 0
// Test code for -stringByTruncatingMiddleToLength:wholeWords:
NSString* s ;

s = @"ThisWordIs23CharacsLong <Dog Smart> (Root)" ;
NSLog(@"%@", [s stringByTruncatingMiddleToLength:28
									  wholeWords:YES]) ;

s = @"It is so sad that nobody bird any more!" ;

NSLog(@"99 %@", [s stringByTruncatingMiddleToLength:99
										 wholeWords:YES]) ;
NSLog(@"44 %@", [s stringByTruncatingMiddleToLength:44
										 wholeWords:YES]) ;
NSLog(@"40 %@", [s stringByTruncatingMiddleToLength:40
										 wholeWords:YES]) ;
NSLog(@"39 %@", [s stringByTruncatingMiddleToLength:39
										 wholeWords:YES]) ;
NSLog(@"36 %@", [s stringByTruncatingMiddleToLength:36
										 wholeWords:YES]) ;
NSLog(@"32 %@", [s stringByTruncatingMiddleToLength:32
										 wholeWords:YES]) ;
NSLog(@"28 %@", [s stringByTruncatingMiddleToLength:28
										 wholeWords:YES]) ;
NSLog(@"24 %@", [s stringByTruncatingMiddleToLength:24
										 wholeWords:YES]) ;
NSLog(@"20 %@", [s stringByTruncatingMiddleToLength:20
										 wholeWords:YES]) ;
NSLog(@"16 %@", [s stringByTruncatingMiddleToLength:16
										 wholeWords:YES]) ;
NSLog(@"12 %@", [s stringByTruncatingMiddleToLength:12
										 wholeWords:YES]) ;
NSLog(@" 8 %@", [s stringByTruncatingMiddleToLength:8
										 wholeWords:YES]) ;
NSLog(@" 4 %@", [s stringByTruncatingMiddleToLength:4
										 wholeWords:YES]) ;
NSLog(@" 1 %@", [s stringByTruncatingMiddleToLength:1
										 wholeWords:YES]) ;
NSLog(@" 0 %@", [s stringByTruncatingMiddleToLength:0
										 wholeWords:YES]) ;
#endif