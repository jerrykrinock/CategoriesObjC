#import "NSHTTPURLResponse+Descriptions.h"


@implementation NSHTTPURLResponse (Descriptions)

- (NSString*)longDescription {
	return [NSString stringWithFormat:
			@"<%@: %p statusCode=%ld Headers: \n%@>\n",
			[self class],
			self,
			(long)[self statusCode],
			[self allHeaderFields]] ;	
}

@end
