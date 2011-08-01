#import "NSCharacterSet+SSYMoreCS.h"


@implementation NSCharacterSet (SSYMoreCS)

+ (NSCharacterSet*)printingAsciiCharacterSet {
	return [NSCharacterSet characterSetWithRange:NSMakeRange(0x21, 0x5f)] ;
}

+ (NSCharacterSet*)filenameLegalUnixCharacterSet {
	NSMutableCharacterSet* set = [[self printingAsciiCharacterSet] mutableCopy] ;
	// Remove the forward slash character
	[set removeCharactersInRange:NSMakeRange(0x2f, 1)] ;
	NSCharacterSet* answer = [set copy] ;
	[set release] ;
	return [answer autorelease] ;
}

+ (NSCharacterSet*)filenameLegalMacUnixCharacterSet {
	NSMutableCharacterSet* set = [[self filenameLegalUnixCharacterSet] mutableCopy] ;
	// Remove the forward slash character
	[set removeCharactersInRange:NSMakeRange(0x3a, 1)] ;
	[set addCharactersInString:@" "] ;
	NSCharacterSet* answer = [set copy] ;
	[set release] ;
	return [answer autorelease] ;
}

- (NSString*)stringOfAllCharacters {
	NSInteger i ;
	NSMutableString* string = [[NSMutableString alloc] init] ;
	for (i=0; i<0x10000; i++) {
		if ([[NSCharacterSet filenameLegalMacUnixCharacterSet] characterIsMember:(unichar)i]) {
			[string appendFormat:@"%c", (unichar)i] ;
		}
	}
	
	NSString* answer = [NSString stringWithString:string] ;
	[string release] ;
	return answer ;
}

+ (NSCharacterSet*)characterSetNotAllowedInUrlHost {
	return [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789.-_"] invertedSet] ;
}

+ (NSCharacterSet*)ssyUsaKeyboardCharacterSet {
	return [NSCharacterSet characterSetWithCharactersInString:@"\r\t\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"] ;
}


+ (NSCharacterSet*)ssyHexDigitsCharacterSet {
	return [NSCharacterSet characterSetWithCharactersInString:@"abcdefABCDEF0123456789"] ;
}

@end
