#import "NSData+HexString.h"

char ASCIIHexCharacterForNibble(short nibble, BOOL uppercaseLetters) {
	char answer ;
	
	short offset ;
	if (nibble < 10) {
		offset = 0x30 ;
	}
	else if (uppercaseLetters) {
		offset = 0x37 ;
	}
	else {
		offset = 0x57 ;
	}
	
	answer = (char)(nibble + offset) ;
	
	return answer ;
}


@implementation NSData (HexString)

- (NSString*)lowercaseHexString {
	// Maybe this could have been done easier by chunking it up into
	// integer-size numbers and using format strings with %x, but 
	// that might have raised endian issues.  I think this way will
	// be endian-agnostic.
	NSInteger i ;
	char hashCString[33] ;
	for (i=0; i<[self length]; i++) {
		NSData* dataChunk = [self subdataWithRange:NSMakeRange(i, 1)] ;
		unsigned char oneByte ;
		[dataChunk getBytes:&oneByte
                     length:1] ;
		NSInteger subscript ;
		subscript = 2*i ;
		hashCString[subscript] = ASCIIHexCharacterForNibble((oneByte & 0xf0) >> 4, NO) ;
		subscript = 2*i+1 ;
		hashCString[subscript] = ASCIIHexCharacterForNibble(oneByte & 0x0f, NO) ;
	}
	hashCString[32] = 0 ; // null termination

	NSString* hashedString = [[NSString alloc] initWithUTF8String:hashCString] ; 
	return [hashedString autorelease] ;
}

@end
