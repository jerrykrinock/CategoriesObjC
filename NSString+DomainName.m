#import "NSString+DomainName.h"


@implementation NSString (DomainName)

- (BOOL)isValidLabelRFC1035 {
	// Make sure that the domain name is a valid "segment in accordance
	// with RFC2396.  Briefly, it must contain only characters a-z, A-Z,
	// 0-9 and -, but - is not allowed to be consecutive and not allowed
	// at the end, and the whole thing must be 63 characters max length.
	// Some quick tests indicate that -[NSURL URLWithString:] seems to
	// take care of the characters but does not check the length.
	if ([self length] > 63) {
		return NO ;
	}

	NSURL* junkUrl = [[NSURL alloc] initWithString:[@"http://" stringByAppendingString:self]] ;
	if (!junkUrl) {
		[junkUrl release] ;
		return NO ;
	}
	
	[junkUrl release] ;
	return YES ;
}


@end
