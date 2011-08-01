#import "NSString+OAuth.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URIQuery.h"
#import "NSData+Base64.h" 


@implementation NSString (OAuth) 

- (NSString*)HMACSHA1SignatureWithSecret:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding] ;
    NSData *clearTextData = [self dataUsingEncoding:NSUTF8StringEncoding] ;
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1,
		   [secretData bytes],
		   [secretData length],
		   [clearTextData bytes],
		   [clearTextData length],
		   result) ;
    
	NSData* signatureData = [NSData dataWithBytes:result
										   length:20] ;
	
	return [signatureData stringBase64Encoded] ;
}

+ (NSString*)stringOAuthWithQueryDictionary:(NSDictionary*)dictionary {
	NSMutableString* string = [NSMutableString string] ;
	NSUInteger countdown = [dictionary count] ;
	// OAuth specification says that keys must be ordered/sorted by
	// ASCII value.
	for (NSString* key in [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)]) {		
		[string appendFormat:@"%@=%@",
		 [key encodePercentEscapesPerStandard:SSYPercentEscapeStandardRFC3986],
		 [[dictionary valueForKey:key] encodePercentEscapesPerStandard:SSYPercentEscapeStandardRFC3986]
		 ] ;
		countdown-- ;
		if (countdown > 0) {
			[string appendString:@"&"] ;
		}
	}
	return [NSString stringWithString:string] ;
}

- (NSString*)stringByPercentEscapeEncodingForOAuth {
	return [self encodePercentEscapesPerStandard:SSYPercentEscapeStandardRFC3986
										  butNot:nil
										 butAlso:nil] ;
}

@end
