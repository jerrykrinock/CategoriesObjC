#import <Cocoa/Cocoa.h>

/*!
 @brief    Constants used to specify the set of characters to be
 percent-escaped encoded in the encoding methods of NSString+URIQuery.
 
 @details  summary: RFC3986 encodes 15 more characters than RFC2396.

 The constant SSYPercentEscapeStandardRFC2396 means the
 character set defined by the union of the following sets:
 * The fourteen characters  ` # % ^ [ ] { } \ | " < > SPACE_CHARACTER_0x20
 * The ASCII control characters
 * The ASCII non-printing characters
 * Any non-ASCII characters (Unicode value > 0xFF)
 
 The constant SSYPercentEscapeStandardRFC3986 means character set
 defined by the union of the following sets:
 * SSYPercentEscapeStandardRFC2396
 * The fifteen characters: ! * ' ( ) ; : @ & = + $ , / ?
*/
enum SSYPercentEscapeStandard_enum {
	SSYPercentEscapeStandardRFC2396,
	SSYPercentEscapeStandardRFC3986 
} ;
typedef enum SSYPercentEscapeStandard_enum SSYPercentEscapeStandard ;


/*!
 @brief    A class for encoding and decoding percent-escaped strings. 
*/
@interface NSString (URIQuery)

/*!
 @brief    Returns a replica of the receiver in which any characters
 in a given set are percent escape encoded.

 @details  The given set is that defined by the parameter standard, minus
 the characters in the string given in the parameter butNot, plus the
 the characters in the string given in the parameter butAlso.
 
 This method does not decode any existing percent escapes in the receiver.
 @param    butNot  String of exceptional characters to be not encoded.  May be nil. 
 @param    butAlso  String of additional characters to be encoded.  May be nil.
*/
- (NSString*)encodePercentEscapesPerStandard:(SSYPercentEscapeStandard)standard
									  butNot:(NSString*)butNot
									 butAlso:(NSString*)butAlso ;

/*!
 @brief    Invokes encodePercentEscapesPerStandard:butNot:butAlso:, passing
 nil for the second and third parameters
 */
- (NSString*)encodePercentEscapesPerStandard:(SSYPercentEscapeStandard)standard ;


/*!
 @brief    Returns a string of the form "key0=value0&key1=value1&...", with
 both keys and values are percent-escape encoded per SSYPercentEscapeStandardRFC2396
 plus the additional three characters + = and ; .

 @details  For compatibility with POST, does not prepend a "?"
 All keys and all values must be NSString objects.
 @param    The  dictionary of keys and values to be encoded into the string
 */
+ stringWithQueryDictionary:(NSDictionary*)dictionary ;

/*!
 @brief   Returns a new string by replacing any percent escape sequences
 with their character equivalents 
 
 @details  Unfortunately, CFURLCreateStringByReplacingPercentEscapes() on which this
 is based seems to only replace %[NUMBER] escapes.
*/
- (NSString*)decodePercentEscapes;

- (BOOL)hasPercentEscapeEncodedCharacters ;

/*!
 @brief    Assuming the receiver is a percent-escape encoded (aka URL encoded)
 UTF8 string, returns a new equivalent string which has any percent-escape
 sequences in given unicode ranges replaced with actual characters, and
 optionally any lowercase hex digits in the remaining percent-escape
 sequences converted to uppercase, and optionally resolves "parent directory"
 double-dot ("..") components in the path

 @details  This method, with indexSet = the single range 0x0080 to 0xFFFF, and
 uppercaseAnyOthers = YES, mimics what happens to the path portion of the URL
 of any bookmark entered into the bookmarks of Safari 13.0.
 
 * TODO / Limitation:
 
 This method does not correctly decode UTF8 sequences whose Unicode values
 U+FFFF, because it stores code points as uint16_t types, and the final
 decoding is done assuming NSUTF16LittleEndianStringEncoding.  I started to try
 and fix this, by changing those to uint32_t and
 NSUTF32LittleEndianStringEncoding (I'm not sure if this would work) until
 I noticed that for my target use case, reverse-engineering what Safari does
 when you enter UTF8 sequences into the path portion of a URL in a bookmark in
 Safari's Edit Bookmarks window, Safari 13.0 does not decode higher-plane
 UTF8 sequences "correctly" either.  The example I tried was to insert sequence
 "%F0%AF%A7%9E" into the path portion of a URL in Safari.  Safari changed it to
 軔 instead of 軔.  Let me explain those:
 
 Enter into URL path:   軔  U+2F9DE  UTF8: F0 AF A7 9E  %F0%AF%A7%9E
 Safari changes it to:  軔   U+8ED4  UTF8: E8 BB 94
 
 Just for the record, the current implementation in this method does this:
 This method decodes:   吏   U+F9DE  UTF8: EF A7 9E
 
 I find the "Safari changes it to" result to be inexplicable.
 
 * Test Code
 
 //-----------------------------------------------------------------------------
 NSString* s;
 NSString* answer;
 NSCharacterSet* targetSet;
 BOOL passed;

 s = @"M%CE%BCd%20flat%ee%a0%A2%ee%a0%A3%wooHOO%%%truck%%5b/1/2/3/4/5/../../bye/";
 targetSet = [NSCharacterSet characterSetWithRange:NSMakeRange(0x80, (0xE823 - 0x80))];
 answer = [s decodeOnlyPercentEscapesInUnicodeSet:targetSet
                               uppercaseAnyOthers:YES
                          resolveDoubleDotsInPath:NO];
 NSLog(@"decoded %ld chars\nIN : %@\nOUT: %@", answer.length, s, answer);
 passed = [answer isEqualToString:@"Mμd%20flat%EE%A0%A3%wooHOO%%%truck%%5B/1/2/3/4/5/../../bye/"];
 NSLog(@"Test 1 %@", passed ? @"passed" : @"failed");

 s = @"M%CE%BCd%20flat%ee%a0%A2%ee%a0%A3%wooHOO%%%truck%%5b/1/2/3/4/5/../../bye/";
 targetSet = [NSCharacterSet characterSetWithRange:NSMakeRange(0x80, (0xE823 - 0x80))];
 answer = [s decodeOnlyPercentEscapesInUnicodeSet:targetSet
                               uppercaseAnyOthers:NO
                         resolveDoubleDotsInPath:YES];
 NSLog(@"decoded %ld chars\nIN : %@\nOUT: %@", answer.length, s, answer);
 passed = [answer isEqualToString:@"Mμd%20flat%ee%a0%A3%wooHOO%%%truck%%5b/1/2/3/bye/"];
 NSLog(@"Test 2 %@", passed ? @"passed" : @"failed");
//-----------------------------------------------------------------------------
 
 @param    targetSet  Set of Unicode code characters (within range 0x0001 thru
 0xffff) which are to be decoded.  Pass nil if no such decoding is desired.
 
 @param    uppercaseAnyOthers  If YES, any lowercase hex digits (a-f) in any
 remaining percent-escape sequences will appear as the corresponding uppercase
 (A-F) in the return string.  If NO, any remaining percent-escape sequences
 will be passed through transparently.  Ignored if targetSet is nil.
 
 @param   resolveDoubleDotsInPath  If YES, considering the receiver to be a
 URL, if the URL has a path component, and if any of those path components
 are "..", removes that path component and the previous path component, unless
 that path component has already been removed by another ".." path component,
 then removes the next previous path component.  For example, if a path
 contains the substring "/1/2/3/4/5/../../../", in the result, this substring
 will be replaced by the substring "/1/2/".
 
 @result  The decoded string, or self if self contains no percent characters.
*/
- (NSString*)decodeOnlyPercentEscapesInUnicodeSet:(NSCharacterSet*)targetSet
                               uppercaseAnyOthers:(BOOL)uppercaseAnyOthers
                          resolveDoubleDotsInPath:(BOOL)resolveDoubleDotsInPath;


/*!
 @brief    Assuming that the receiver is a query string of key=value pairs,
 of the form "key0=value0&key1=value1&...", , returns a dictionary of the keys
 and values, with any percent-escape encoded sequences decoded.

 @details  Understands both ampersand "&" and semicolon ";" to delimit key-value
 pairs.  The latter is recommended here:
 http://www.w3.org/TR/1998/REC-html40-19980424/appendix/notes.html#h-B.2.2
 */
- (NSDictionary*)queryDictionary;

/*! @brief    Returns the location of the third slash character in the receiver
 
 @details  This is more "loose" method than going via NSURLComponents, which
 is quite strict.  For example, attempting to create a NSURLComponenets object
 with a string that does not totally conform to RFC2396 will result in nil.
 This method will succeed.
 
 @result   The location of the third slash, or NSNotFound if the receiver does
 not contain three slashes.
 */
- (NSRange)pathRangeLoosely;

@end

