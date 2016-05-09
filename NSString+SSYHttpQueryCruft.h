#import <Foundation/Foundation.h>

extern NSString* constKeyCruftDeskription ;
extern NSString* constKeyCruftDomain ;
extern NSString* constKeyCruftKey ;
extern NSString* constKeyCruftKeyIsRegex ;

/*!
 @brief    Category on NSString which contains a method for surgically 
 removing selected query key/value pairs (deemed to be "cruft")
 
 @details  As an alternative to creating this category, I also considered
 doing this by operating on the whole URL with regular expressions.  That way,
 I could use the existing Find/Replace feature.

 For example, to remove Google's Urchin Traffic Monitor key/value pairs,
 I tried this Find pattern:
 (.+)([\?\&]utm_(reader|source|medium|term|campaign|content)=[^&#]+)(.*),
 and Replace with:
 $1$3
 That worked on this URL:
 http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff
 although it only deleted one key/value pair, the last one, and to delete all
 5 of them required 5 passes.  Also, and I don't get this, it failed to find
 when I inserted a non-crufty key/value pair "&foo=bar" into the middle and the
 last cruft after that was removed:
 http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&foo=bar&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff
 
 Conclusion: Regular Expressions are nice when they work, but if things get
 too complicated and another way is available, use another way.
 */
@interface NSString (SSYRemoveHttpQueryCruft)

/*!
 @brief    Returns an array of ranges created by NSRangeFromString(), each of
 which represents the range of a query key/value pair in the receiver that
 matches one or more of given QueryCruftSpec objects, omitting the delimiter
 characters '?', '&' and ';'
 
 @param    error_p  Pointer which will, upon return, if the receiver parses as
 a URL string, and has a query string, and one of the given query cruft objects
 is an unparseable regular expression and error_p is not NULL, point to an
 NSError indicating the failure to parse.

 @result   Returns nil if any of the following three occurs:
 
 • No key/value pairs matched any of the given query cruft specs
 (implying that the receiver does not contain any cruft).
 
 • The receiver does not parse as a URL string.
 
 • An error (which will be returned in error_p) occurs.
 */

- (NSArray <NSString*> *)rangesOfQueryCruftSpecs:(NSArray <NSDictionary*> *)cruftSpecs
                                         error_p:(NSError**)error_p ;


/*!
 @brief    Presuming that the receiver is a URL string, and given a set of
 strings which can be converted to ranges with NSRangeFromString(), and
 presuming that each of these ranges represents the range of a key/value
 pair in the receiver, not including the preceding '?', '&' or ';' delimiter,
 removes the indicated key/value pairs and any associated '?', '&' or ';'
 delimiters  required so that the result is a valid URL string again, and
 returns this result
 
 @details  If all key/value pairs are removed, the '?' delimiter is removed.
 If no key/value pairs are removed, returns the receiver itself.
*/
- (NSString*)urlStringByRemovingCruftyQueryPairsInRanges:(NSArray <NSString*> *)ranges ;

@end


