#import <Cocoa/Cocoa.h>


@interface NSData (Crypt)

// Utility method for generating keys from string passwords
+ (NSData*)dataKeyByteCount:(int)nKeyBytes
			 from7BitString:(NSString*)password ;
	// nKeyBytes may be of
	// any length, although if you believe the fiction that 
	// making it incredibly easy for the U.S. government to eavesdrop
	// is somehow protecting the world from terrorists, I believe USA
	// citizens are supposed to limit nKeyBytes to maximum 7 (56 bits)
	// or something stupid like that, in any exported product.
	
	// Password will be converted to a null-terminated UTF8 string and 
	// the most significant bit of each byte will be ignored.
	// Therefore, if password is all 127-bit low ASCII, the number of
	// characters required is ceil(nKeyBytes/7).
	
	// Because the null-termination is detected, the NUL character
	// (Unicode U+0000) is not allowed in the password.  (According to
	// Wikipedia, NUL is the only UTF8 sequence which includes the
	// byte 0x00.)
	
	// To determine the number of bytes in a password with non-ASCII
	// characters, you may use -[NSString lengthOfBytesUsingEncoding:]
	// with argument NSUTF8StringEncoding (requires Mac OS 10.4 or later).
	
// Since RC4 is a symmetric stream encryption, the same method
// is used for encrypting and decrypting.
- (NSData*)cryptRC4WithKeyData:(NSData*)keyData ;	
	// Data returned will be same byte count (-length) as receiver.	

@end
