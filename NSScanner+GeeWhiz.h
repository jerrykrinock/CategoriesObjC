#import <Cocoa/Cocoa.h>

@interface NSScanner (GeeWhiz)

/*!
 @brief    scans up to and then leaps over a given string

 @details  A more useful version of Apples scanUpToString:intoString.  Scans up to stopString.
 If stopString is present in the receiver's string, it returns that part in stringValue, and then
 leaps over stopString so that, upon return, receiver's scanLocation is after stopString.
 If the stopString is not present in the receiver's string, the remainder of the source string is
 put into stringValue, and the receiver’s scanLocation is advanced to the end.
 @param    stopString  string that is being scanned for
 @param    stringValue  Upon return, a pointer to the part of the receiver's string which
 was scanned BEFORE stopString was leaped over
 @result   YES if stopString was found and leaped over, NO if not found.  Note
 that this result differs from that of Apple's scanUpToString:intoString which returns
 "YES if the receiver scans any characters".  That's not usually what I want!
 */
- (BOOL)scanUpToAndThenLeapOverString:(NSString*)stopString
						   intoString:(NSString**)stringValue ;

- (BOOL)tryScanPastString:(NSString*)target ;
// Tries to scan past target.
// If target is found, sets scanLocation to the next
// character past target and returns YES.
// If target not found, sets scanLocation back to where
// it originally was and returns NO.

@end

