#import "NSData+Base64.h" 
#import "NSScanner+GeeWhiz.h"
#import "NSString+Base64.h"
#import "NSString+SSYExtraUtils.h"

@implementation NSData (Base64)

- (NSData*)dataBase64Encoded {
	NSString* encodedString = [self stringBase64Encoded] ;
	return [encodedString dataUsingEncoding:NSASCIIStringEncoding] ;
}

- (NSData*)dataBase64Decoded {
	NSString* encodedString = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding] ;
	NSData* decodedData = [encodedString dataBase64Decoded] ;
	[encodedString release] ;
	return decodedData ;
}

- (NSString*)stringBase64Encoded {
	/* I sneakily insert the binary into an XML serialization of an 
	empty property list and then decode the property list. My data is 
	always very small, so this works for me. */
	
	NSData* xmlData = [NSPropertyListSerialization dataWithPropertyList:self
                                                                 format:NSPropertyListXMLFormat_v1_0
                                                                options:0
                                                                  error:NULL] ;
	
	
	NSMutableString* xml = [[NSMutableString alloc] initWithData:xmlData encoding:NSASCIIStringEncoding] ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:xml] ;
	NSString* b64 ;
	[scanner scanUpToAndThenLeapOverString:@"<data>" intoString:NULL] ;
	[scanner scanUpToString:@"</data>" intoString:&b64] ;
	[xml release] ;
	[scanner release] ;
	return [b64 trimNewlineFromEnd] ;
}

- (NSString*)stringBase64Decoded {
	NSData* decodedData = [self dataBase64Decoded] ;
	NSString* decodedString = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding] ;
	return [decodedString autorelease] ;
}

@end
