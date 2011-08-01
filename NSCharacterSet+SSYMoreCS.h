#import <Cocoa/Cocoa.h>

@interface NSCharacterSet (SSYMoreCS)

/*!
 @brief    Returns a character set of the 95 ASCII
 characters that print.
*/
+ (NSCharacterSet*)printingAsciiCharacterSet ;

/*!
 @brief    Returns a character set of the 95 characters
 that are legal in unix filenames.

 @details  This is +printingAsciiCharacterSet, plus
 the space character, minus the forward slash.
*/
+ (NSCharacterSet*)filenameLegalUnixCharacterSet ;

/*!
 @brief    Returns +filenameLegalUnixCharacterSet,
 minus the colon character, a total of 94 characters.
*/
+ (NSCharacterSet*)filenameLegalMacUnixCharacterSet ;

/*!
 @brief    Prints a string containing one each of all the characters
 in the receiver.

 @details  Warning: There are 65535 possible characters in Unicode,
 I believe.&nbsp; This method is mainly for debugging.
*/
- (NSString*)stringOfAllCharacters ;

/*!
 @brief    Returns the character set of all Unicode characters which are
 not allowed to be in the 'host' portion of a URL.
 
 @details  See http://en.wikipedia.org/wiki/Hostname ▸ Restrictions on valid host names
 */
+ (NSCharacterSet*)characterSetNotAllowedInUrlHost ;

/*!
 @brief    Character set consisting of all the printing and non-printing characters you can
 type on a USA keyboard, using on the shift key as modifier.
*/
+ (NSCharacterSet*)ssyUsaKeyboardCharacterSet ;

+ (NSCharacterSet*)ssyHexDigitsCharacterSet ;

@end
