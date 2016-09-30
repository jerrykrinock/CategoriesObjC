#import <Cocoa/Cocoa.h>


@interface NSArray (DespoofStrings)

/*!
 @brief    For an array of strings, if any string contains a given string,
 replaces all occurrences of a given 'target' string in any of them with another
 given 'replacemeent' string and returns a new array, otherwise returns nil.

 @details  The receiver must be a set of NSString objects.  If either parameter
 is nil, this method returns nil.
 @result   Either a copy of the receiver with the spoofs replaced, or nil.
 */
- (NSArray*)replaceOccurrencesOfString:(NSString*)target
							withString:(NSString*)replacement ;

@end
