#import <Cocoa/Cocoa.h>


@interface NSArray (DespoofStrings)

/*!
 @brief    For an array of strings, if any string contains a given string, replaces all
 occurrences of a given string in any of them with another given string and returns a
 new array, otherwise returns nil.

 @details  The receiver must be a set of NSString objects.  If one or more spoofs are
 found in any member of the receiver, returns a new array, a copy of the receiver, but with
 the spoofs replaced by the underscore ("_") character.  If no spoofs are found
 in any string in the receiver, returns nil.
 @result   Either a copy of the receiver with the spoofs replaced, or nil.
 */
- (NSArray*)replaceOccurrencesOfString:(NSString*)target
							withString:(NSString*)replacement ;

@end
