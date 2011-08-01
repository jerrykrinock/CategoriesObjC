#import "NSURL+OAuth.h"


@implementation NSURL (OAuth)

- (NSString*)normalizedUrlForOAuth {
	NSString* scheme = [self scheme] ;
	NSString* host = [self host] ;
	NSNumber* portNumber = [self port] ;
	NSString* path = [self path] ;
	
	NSString* port ;
	if (portNumber) {
		port = [NSString stringWithFormat:@"%d", portNumber] ;
	}
	else {
		port = [scheme isEqualToString:@"http"] ? @"80" : @"443" ;
	}
	
	if (
		([scheme isEqualToString:@"http"] && ![port isEqualToString:@"80"])
		||		
		([scheme isEqualToString:@"https"] && ![port isEqualToString:@"443"])
		) {
		host = [NSString stringWithFormat:
				@"%@:%@",
				host,
				port] ;
	}
	
	return [NSString stringWithFormat:
			@"%@://%@%@",
			scheme,
			host,
			path] ;
}

@end

