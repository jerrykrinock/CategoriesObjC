#import <Cocoa/Cocoa.h>

/*!
 @brief    Constants used to define the standard which specifies
 the set of characters to be percent-escaped encoded in the 
 encoding methods of NSString+URIQuery.
 
 @details  Encoding is based on CFURLCreateStringByAddingPercentEscapes.
 The documentation of CFURLCreateStringByAddingPercentEscapes
 says that it escapes characters which are "not legal URL characters
 (based on RFC 2396)".  However, the word "legal" does not appear in
 RFC 2396, and in fact there are several categories of characters.
 
 So, I did an experiment to find out which ASCII characters are encoded,
 by encoding a string with all the nonalphanumeric characters available on the
 Macintosh keyboard, with and without the shift key down, and feeding this
 into CFURLCreateStringByAddingPercentEscapes.  The result was that fourteen
 characters were encoded:  ` # % ^ [ ] { } \ | " < > SPACE_CHARACTER
 This agrees with the union of the lists of "space" "delims" and "unwise" in
 RFC 2396 sec. 2.4.3.  So I assume that this is what Apple means by "not legal".
 Also, I found that all of the non-ASCII characters available on the Macintosh 
 keyboard by using option or shift+option are also encoded.  Some of these have
 two bytes of unicode to encode, for example %C2%A4 for 0xC2A4.

 Therefore, the constant SSYPercentEscapeStandardRFC2396 means the
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
 @brief    Returns a replica of the receiver in which any existing percent
 escapes sequences which decode to characters not in the set defined by
 SSYPercentEscapeStandardRFC2396 are decoded, and any characters in the
 set defined by SSYPercentEscapeStandardRFC2396 are encoded.
*/
- (NSString*)encodePercentEscapesStrictlyPerRFC2396 ;



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

/*  @brief   Returns a new string by replacing any percent escape sequences
 with their character equivalents 
 
 @details  Unfortunately, CFURLCreateStringByReplacingPercentEscapes() on which this
 is based seems to only replace %[NUMBER] escapes.
 Not sure how this is different than -stringByReplacingPercentEscapesUsingEncoding:
 Performing test in implementation to see if I can use that instead of this.
 */
- (NSString*)decodeAllPercentEscapes ;

/*!
 @brief   Returns a new string by replacing specified percent escape sequences
 with their character equivalents 
 
 @details  Unfortunately, CFURLCreateStringByReplacingPercentEscapes() on which this
 is based seems to only replace %[NUMBER] escapes.
 @param    butNot  String of exceptional characters to be not encoded.  May be nil. 
*/
- (NSString*)decodePercentEscapesButNot:(NSString*)butNot ;

- (NSString*)stringByFixingPercentEscapes ;

- (BOOL)hasPercentEscapeEncodedCharacters ;

#if 0
/*!
 @brief    This method is not needed.

 @details  If you want to decode only a small number of characters, first use
 -decodeAllPercentEscapes, then one of the -encodePercentEscapes… methods
 @param    only  
 @result   
*/
- (NSString*)decodePercentEscapesOnly:(NSString*)only ;
#endif

/*!
 @brief    Assuming the receiver is a percent-escape encoded (aka URL encoded)
 UTF8 string, returns a new equivalent string which has all percent-escape sequences
 in given unicode ranges replaced with actual characters..

 @details  If the receiver contains no percent escape sequences, efficiently returns self.
 @param    indexSet
 @result
*/
- (NSString*)decodeOnlyPercentEscapesInUnicodeIndexSet:(NSIndexSet*)indexSet;


/*!
 @brief    Assuming that the receiver is a query string of key=value pairs,
 of the form "key0=value0&key1=value1&...", , returns a dictionary of the keys
 and values, with any percent-escape encoded sequences decoded.

 @details  Understands both ampersand "&" and semicolon ";" to delimit key-value
 pairs.  The latter is recommended here:
 http://www.w3.org/TR/1998/REC-html40-19980424/appendix/notes.html#h-B.2.2
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding ;

@end

