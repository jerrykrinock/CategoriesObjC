#import "NSHTTPURLResponse+Descriptions.h"


@implementation NSHTTPURLResponse (Descriptions)

- (NSString*)longDescription {
	return [NSString stringWithFormat:
			@"<%@: %p statusCode=%d Headers: \n%@>\n",
			[self class],
			self,
			[self statusCode],
			[self allHeaderFields]] ;	
}

@end
