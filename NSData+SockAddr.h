#import <Cocoa/Cocoa.h>


@interface NSData (SockAddr)

/*!
 @brief    Assuming that the receiver's bytes are a sockaddr
 data struture, extracts the IPv4 address as a string in "dot"
 notation.

 @details  	Was adapted from code in an Apple Tech QA:
 *  http://developer.apple.com/qa/qa2001/qa1298.html
 May crash if the receiver's bytes are not a sockaddr
 data structure.
 @result   A string such as @"10.0.1.219", or nil if the 
 receiver was a sockaddr data structure but did not contain an
 IPv4 address.
*/
- (NSString*)dottedIPv4Address ;

@end
