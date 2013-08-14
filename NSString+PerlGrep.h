#import <Cocoa/Cocoa.h>


@interface NSString (PerlGrep)

/*!
 @brief    Performs a pattern match in Perl upon the receiver and
 returns the result
 
 @details  Spawns a perl process with a timeout of 1.0 seconds and
 waits for it to exit
 @param    matchPattern  A Perl regex string.  If you hard-code this
 as NSString constant using @"whatever", remember that, besides \ escaping any
 quotes, you'll also need to \ escape any \ by typing \\.  Matches
 are captured by (…).  See perlre in the Perl documentation.
 @param    outPattern  The string you want returned, containing
 placeholders $1, $2, … into which will be substituted the matches
 captured.  These are optional, but without them this method will
 simply return a replica of the receiver.
 @param    error_p  If not NULL and if an error occurs, upon return,
 will point to an error object encapsulating the error.
 @result   A replica of outPattern, with the matches captured in the
 receiver substituted in for $1, $2, $3, etc.
 */
- (NSString*)stringByGreppingMatchPattern:(NSString*)matchPattern
							   outPattern:(NSString*)outPattern
								  error_p:(NSError**)error_p ;

/*!
 @brief    Extracts the first valid email from the receiver and returns it
 
 @details  "Valid email" has some corner cases and fuzzy edges.
 We do a pretty good job.  See RFC 1123, 2821, 2822.
 @result   The first email address found, or nil if none is found
 */
- (NSString*)extractEmail ;

@end
