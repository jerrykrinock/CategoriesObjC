#import <Cocoa/Cocoa.h>


@interface NSArray (DespoofStrings)

/*!
 @brief    For an array of strings, replaces all occurrences of a given character
 with the underscore character and returns a new array.

 @details  The receiver must be a set of NSString objects.  If one or more spoofs are
 found in any member of the receiver, returns a new array, a copy of the receiver, but with
 the spoofs replaced by the underscore ("_") character.  If no spoofs are found
 in any string in the receiver, returns nil.
 @param    delimiter  A string of length 1, the character to be replaced.
 @result   Either a copy of the receiver with the spoofs replaced, or nil.
 */
- (NSArray*)replaceByUnderscoreOccurrencesInStringsOfCharacter:(NSString*)delimiter ;

@end
