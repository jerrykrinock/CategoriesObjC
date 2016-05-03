#import <Foundation/Foundation.h>

@interface QueryCruftSpec : NSObject

@property (copy) NSString* domain ;
@property (copy) NSString* key ;
@property (assign) BOOL keyIsRegex ;

@end


/*!
 I also considered doing this by operating on the whole URL with regular
 expressions.  That way, I could use the existing Find/Replace feature.
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
 @brief    Returns a replica of the receiver, omitting from the query part of
 the receiver any key/value pairs which match one or more of given 
 QueryCruftSpec objects
 
 @details  We don't return the error from NSRegularExpression because it's not
 very informative.  It only says that the pattern could not be parsed. 
 
 @result   If no key/value pairs matched any of the given query cruft specs
 (implying that the receiver does not contain any cruft), returns the receiver.
 
 If the receiver does not parse as a URL string, returns the receiver.
 
 If the receiver parses as a URL string, and has a query string, but one of the
 given query cruft objects is an unparseable regular expression, returns nil.
 This should be considered to be an error.  In this case, if error_p is not
 NULL, it will point to an error.
 */
- (NSString*)urlStringByRemovingQueryCruftSpecs:(NSArray <QueryCruftSpec*> *)cruftSpecs
                                        error_p:(NSError**)error_p ;

@end


