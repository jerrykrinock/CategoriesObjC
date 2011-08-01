#import "NSString+Data.h"

@implementation NSString (Data)

+ (NSString*)stringWithData:(NSData*)data
				   encoding:(NSStringEncoding)encoding {
	return [[[NSString alloc] initWithData:data
								  encoding:encoding] autorelease] ;
}

+ (NSString*)stringWithDataUTF8:(NSData*)data {
	return [self stringWithData:data
					   encoding:NSUTF8StringEncoding] ;
}

@end
