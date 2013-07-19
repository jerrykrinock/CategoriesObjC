#import "NSData+SockAddr.h"
#include <arpa/inet.h>

@implementation NSData (SockAddr)

- (NSString*)dottedIPv4Address {
	struct sockaddr* socketAddress = (struct sockaddr *)[self bytes];
	NSString* dottedIPv4Address = nil ;
	
	/* Only continue if this is an IPv4 address. */
	if (socketAddress && socketAddress->sa_family == AF_INET) {
		char buffer[256] ;		
		if (inet_ntop(AF_INET, &((struct sockaddr_in *)
								 socketAddress)->sin_addr, buffer, sizeof(buffer))) {
			dottedIPv4Address = [NSString stringWithCString:buffer
												   encoding:NSASCIIStringEncoding] ;
		}
	}
	
	return dottedIPv4Address ;
}

@end
