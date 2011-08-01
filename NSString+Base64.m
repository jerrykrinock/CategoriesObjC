#import "NSString+Base64.h" 
#import "NSData+Base64.h" 

@implementation NSString (Base64)

- (NSString*)stringBase64Encoded {
	NSData* encodedData = [self dataBase64Encoded] ;
	NSString* encodedString = [[NSString alloc] initWithData:encodedData encoding:NSASCIIStringEncoding] ;
	return [encodedString autorelease] ;
}

- (NSString*)stringBase64Decoded {
	NSData* decodedData = [self dataBase64Decoded] ;
	NSString* decodedString = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding] ;
	return [decodedString autorelease] ;
}

- (NSData*)dataBase64Encoded {
	NSData* decodedData = [self dataUsingEncoding:NSASCIIStringEncoding] ;
	return [decodedData dataBase64Encoded] ;
}

- (NSData*)dataBase64Decoded {
	// This worked, but I decided it was too cheesy so I used NSDataBase64.h/m instead
	// But then I found that had a bug in it so I switched back to this.
	
	/*	http://www.cocoabuilder.com/archive/message/cocoa/2005/6/9/138359	
	
FROM : Steven Kramer
DATE : Thu Jun 09 18:43:55 2005
	
	I used this as a quick hack. It uses the property list base 64 decoder. 
	I sneakily insert the base 64 string into an XML serialization of an 
	empty property list and then decode the property list. My data is 
	always very small, so this works for me.
	
	Steven Kramer  http://www.sprintteam.nl/  */
	
	NSMutableData* data = [[[NSMutableData alloc] init] autorelease];
	data = [[[NSPropertyListSerialization dataFromPropertyList: data 
														format: NSPropertyListXMLFormat_v1_0
											  errorDescription: nil] 
		mutableCopy] autorelease];
	char nul = 0;
	[data appendBytes:&nul length:1];
	NSMutableString* plist = [NSMutableString stringWithUTF8String:(const char*)([data bytes])] ;
	[plist replaceOccurrencesOfString:@"<data>"
						   withString:[@"<data>" stringByAppendingString:self]
						      options:0
						        range: NSMakeRange (0, [plist length])];
	//NSLog(@"plist =\n%@\n", plist) ;
	data = [[[NSPropertyListSerialization propertyListFromData:[NSData dataWithBytes:[plist UTF8String] length: [plist length]] 
											  mutabilityOption:NSPropertyListImmutable
											            format:nil
											  errorDescription:nil] mutableCopy] autorelease];
	//NSLog(@"data =\n%@\n", data) ;
	return [[data retain] autorelease] ;
}

+ (NSCharacterSet*)base64CharacterSet {
	return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/="] ;
}

@end
