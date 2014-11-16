#import <Cocoa/Cocoa.h>

@interface NSString (SSYExtraUtils)

/*!
 @brief    Returns a string equivalent to a given Pascal string
*/
+ (NSString*)stringWithPascalString:(ConstStr255Param)pascalString
						   encoding:(CFStringEncoding)encoding ;

- (NSRange)wholeRange ;


- (NSUInteger)numberOfOccurrencesOfCharacter:(unichar)aChar ;

/*!
 @brief    
 
 @details   From Omni Group's NSString-OFExtensions.m
 Can be better than making a mutable copy and calling
 -[NSMutableString replaceOccurrencesOfString:withString:options:range:]
 if stringToReplace is not found in the receiver, then the receiver is retained,
 autoreleased, and returned immediately. 
 */
- (NSString*)stringByReplacingAllOccurrencesOfString:(NSString *)stringToReplace
										  withString:(NSString*)replacement ;

/*!
 @brief    Finds all runs of consecutive blank spaces (code 0x20 only)
 and replaces them with one blank space (code 0x20).

 @details  Todo: Make this find any whitespace.  Would probably
 need to use NSScanner, scanning for characters in set.
 @result   A replica of the receiver, possibly with spaces removed.
*/
- (NSString*)stringByCollapsingConsecutiveSpaces ;

/*!
 @brief    If receiver contains any of the three newline characters which
 define -[NSCharacterSet newlineCharacterSet], replaces each such character with
 an ASCII space (0x20) and returns this modified string; otherwise, returns
 the receiver
 
 @details  The effect replicates what Google Chrome does to bookmark names
 (tested with Google Chrome version 40).
 */
- (NSString*)stringByReplacingNewlinesWithSpaces ;

/* I don't quite understand these... */
- (FourCharCode)fourCharCodeValue ;
// Old code for big endian.  Gives string backwards for little endian:
+ (NSString*)stringWithFourCharCode:(OSType)osType ;

- (BOOL)containsString:(NSString*)target ;

- (BOOL)isMinimumLength:(NSNumber*)minLength ;

/*!
 @brief    Returns whether or not the receiver is a string
 in the form "i.j.…", where i, j, … are each strings of decimal
 digits, and where at least one of them has a nonzero value.
 */
- (BOOL)isValidVersionString ;

/*!
 @brief    Returns the substring of the receiver which
 best gives an app or bundle version string, or nil if
 such a substring cannot be found, according to a
 complicated algorithm which is best illustrated by
 example.

 @details  See test code at end of this file.
 Examples:
 "App4U version 1.0.0 (123)" returns "1.0.0"
 "App4U version 123" returns "123"
 "App4U 1.0.0" returns "1.0.0"
 "App4U 1.0.0b" returns "1.0.0"
 "App4U 1.0.0 (1.1.1)" returns "1.1.1"
 "App4U" returns "(null)"
 "App4U 5" returns "5"
 */
- (NSString*)versionSubstring ;

/*!
 @brief    Returns the integer value of the receiver's -versionSubstring,
 which will its the number before the first decimal point.
 
 @details  See test code at end of this file.
 Examples:
 "App4U version 1.0.0 (123)" returns 1
 "App4U version 123" returns 123
 "App4U 1.0.0" returns 1
 "App4U 1.0.0b" returns 1
 "App4U 1.0.0 (1.1.1)" returns 1
 "App4U" returns 0
 "App4U 5" returns 5
*/
- (NSInteger)majorVersion ;

/*!
 Returns a numberWithBool
 */
- (NSNumber*)isValidEmail ;

- (NSString*)stringByRemovingLastCharacters:(NSInteger)n ;

- (NSInteger)occurrencesOfSubstring:(NSString*)target inRange:(NSRange)range ;

/*!
 @brief    Returns 1 plus the number of ASCII \n characters in a
 given string, which is usually the number of "lines".

 @details  Indeed gives the number of lines if the receiver has DOS or
 UNIX line endings "\n\r" or "\n".  Fails if the line endings are "\r".
 @param    countTrailer  YES if a trailing newline should be counted
 as a line, NO if not.
*/
- (NSInteger)numberOfLinesCountTrailer:(BOOL)countTrailer ;

- (NSString*)stringByRemovingCharactersInSet:(NSCharacterSet*)characterSet ;

- (NSString*)stringByReplacingCharactersInSet:(NSCharacterSet*)characterSet withString:(NSString*)string ;

- (NSString*)substringSafelyWithRange:(NSRange)range ;

/*!
 @brief    If the first character of the string is a lower-case ASCII
 character, returns a new string with this character replaced by its
 capitalized counterpart; otherwise, returns self.
 
 @details  The difference between this method and Apple's
 -capitalizedString is that this method does not un-capitalize characters
 in the midst of the string.&nbsp; This method is therefore useful for
 capitalizing keys in KVC.
 */
- (NSString*)capitalize ;

/*!
 @brief    Returns a new string which is identical to the receiver
 except for the appending of a colon.
 */
- (NSString*)colonize ;

/*!
 @brief    Returns a new string which is identical to the receiver
 except that a doublequote is prepended and appended.
 */
- (NSString*)doublequote ;

/*!
 @brief    Returns a new string which is identical to the receiver
 except for the appending of an ellipsis (Unicode 0x2026).
*/
- (NSString*)ellipsize ;

/*!
 @brief     Copies the receiver the receiver, removes any newline character and
 returns the copy, except if there is no newline then returns nil.
*/
- (NSString*)trimNewlineFromEnd ;

- (BOOL)isAllWhite ;

- (NSString *)stringByDecodingXMLEntities ;

/*!
 @brief    Returns an autoreleased copy of the receiver with the first
 character last and the last character first, etc.

 @details  Only works if all characters in the receiver are 1 byte (ASCII).
*/
- (NSString*)reverseAsciiChars ;

/*!
 @brief    Returns the string of contiguous decimal digits which are the
 receiver's suffix.
 
 @details  If the last character of the receiver is not a decimal digit,
 returns an empty string.
*/
- (NSString*)decimalDigitSuffix ;


- (BOOL)isValidUrl ;

/*!
 @brief    Parses the receiver and tries to extract a valid URL string
 and a valid name string.

 @details  If the receiver contains a tab character, returns
 the part before the tab in name_p and returns the part after the tab,
 if it is a valid URL.  If the receiver does not contain a tab
 character, returns nil in name_p and returns the receiver if it is
 a valid URL.  If the required part is not a valid URL, returns nil.
 @param    name_p  If you pass a non-nil pointer, upon return, points
 to the parsed name or to localized "untitled" if no name was parsed.
 You may pass NULL if you don't want the name.
*/
- (NSString*)parseForUrlAndName_p:(NSString**)name_p ;

/*!
 @brief    Returns a replica of the receiver, with any
 NSAttachmentCharacter characters removed
 
 @details  Adapted from Keith Blount, see
 http://lists.apple.com/archives/cocoa-dev/2006/Sep/msg00001.html
 */
- (NSString*)stringByOmittingAttachmentCharacters ;

@end


@interface NSMutableString (SSYExtraUtils)

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target
								withString:(NSString *)replacement ;

@end

#if 0
// Test code for -versionSubstring and -majorVersion:
NSString* s ;

NSLog(@"\nTesting -versionSubstring") ;

s = @"6.0" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"6.0a2" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U version 1.0.0 (123)" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U version 123" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U 1.0.0" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U 1.0.0b6" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U 1.0.0 (2.1.1)" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

s = @"App4U 5" ;
NSLog(@"\"%@\" returns \"%@\"", s, [s versionSubstring]) ;

NSLog(@"\nTesting -majorVersion") ;

s = @"6.0" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"Aurora 6.0a2" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U version 1.0.0 (123)" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U version 123" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U 1.0.0" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U 1.0.0b6" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U 1.0.0 (2.1.1)" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

s = @"App4U 5" ;
NSLog(@"\"%@\" returns %ld", s, (long)[s majorVersion]) ;

exit(0) ;

// OUTPUT

Testing -versionSubstring
"6.0" returns "6.0"
"6.0a2" returns "6.0a2"
"App4U version 1.0.0 (123)" returns "1.0.0"
"App4U version 123" returns "123"
"App4U 1.0.0" returns "1.0.0"
"App4U 1.0.0b6" returns "1.0.0b6"
"App4U 1.0.0 (2.1.1)" returns "2.1.1"
"App4U" returns "(null)"
"App4U 5" returns "5"

Testing -majorVersion
"6.0" returns 6
"Aurora 6.0a2" returns 6
"App4U version 1.0.0 (123)" returns 1
"App4U version 123" returns 123
"App4U 1.0.0" returns 1
"App4U 1.0.0b6" returns 1
"App4U 1.0.0 (2.1.1)" returns 2
"App4U" returns 0
"App4U 5" returns 5

#endif

#if 0
// Test code for CFXMLCreateStringByUnescapingEntities and
// PatchedCFXMLCreateStringByUnescapingEntities

NSString* ValidateString(NSString* s) {
    const char* cString = [s UTF8String] ;
    return (cString != NULL) ? s : nil ;
}

void TestString(NSString* s, NSString* expected) {
    NSLog(@"Testing:        (len=%03ld): %@", (long)[s length], s) ;
    NSLog(@"     Expected Result (len=%03ld): '%@'", [expected length], expected) ;
    
    // Try Apple's function
    NSString* result1 = (__bridge NSString*)CFXMLCreateStringByUnescapingEntities(NULL, (__bridge CFStringRef)s, NULL) ;
    NSString* result1a = ValidateString(result1) ;
    if (result1 != NULL) {
        CFRelease((CFStringRef)result1) ;
    }
    NSString* passFail1 = [expected isEqualToString:result1] ? @"PASS" : @"FAIL" ;
    NSLog(@"   Apple Result %@ (len=%03ld): '%@'", passFail1, [result1 length], result1a) ;
    
    // Try patched function
    NSString* result2 = (__bridge NSString*)PatchedCFXMLCreateStringByUnescapingEntities(NULL, (__bridge CFStringRef)s, NULL) ;
    NSString* result2a = ValidateString(result2) ;
    NSString* passFail2 = [expected isEqualToString:result2] ? @"PASS" : @"FAIL" ;
    NSLog(@" Patched Result %@ (len=%03ld): '%@'", passFail2, [result2 length], result2a) ;
    if (result2 != NULL) {
        CFRelease((CFStringRef)result2) ;
    }
}

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        TestString(
                   @"Hello&#160;World",
                   @"Hello\u00A0World"
                   ) ;
        TestString(
                   @"&apos;Hello&amp;World&apos;",
                   @"'Hello&World'"
                   ) ;
        TestString(
                   @"Here is a gamma: &#915;.  Here is a dagger: &#8224;",
                   @"Here is a gamma: \u0393.  Here is a dagger: \u2020"
                   ) ;
        TestString(
                   @"Hello&#8224World",
                   @"Hello&#8224World"
                   ) ;
        TestString(
                   @"&#13207494",
                   @"&#13207494"
                   ) ;
        TestString(
                   @"Hello&",
                   @"Hello&"
                   ) ;
        TestString(
                   @"&Hello&",
                   @"&Hello&"
                   ) ;
    }
    return 0;
}

#endif