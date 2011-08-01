#import <Cocoa/Cocoa.h>


@interface NSString (UserAgents)

/*!
 @brief    Assuming that the receiver is a HTTP UserAgent string
 tries to extract the name of the web browser

 @details  May return nil if name cannot be extracted.
 
 Determining the browser from a User-Agent string is actually
 quite difficult, and 100% accuracy is probably impossible.
 These people are trying really hard to be accurate:
 
 http://www.browserscope.org/
 
 Unit Test is available for this category.
*/

- (NSString*)browserNameFromUserAgentStringAmongCandidates:(NSArray*)candidates ;

@end
