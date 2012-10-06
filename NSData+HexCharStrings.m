#import "NSData+HexCharStrings.h"

@implementation NSData(HexCharacterStrings)

+ (NSData*)dataWithHexCharacterString:(NSString*)string {
	NSScanner* outerScanner = [[NSScanner alloc] initWithString:string] ;
	NSMutableData* data = [[NSMutableData alloc] init] ;
	while (![outerScanner isAtEnd]) {
		NSString* piece = nil ;
		[outerScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
								 intoString:&piece] ;
		NSInteger loc = 0 ;
		while (loc < [piece length]) {
			const char* byteString = [[piece substringWithRange:NSMakeRange(loc, 2)] UTF8String] ;
			int16_t byte ;
			sscanf(byteString, "%hx", &byte) ;
			// Adjustment for endian on PowerPC may be needed here?
			loc += 2 ;
			[data appendBytes:&byte
					   length:1] ;
		}
	}
	[outerScanner release] ;
	
	NSData* answer = [data copy] ;
	[data release] ;
	
	return [answer autorelease] ;
}

@end
