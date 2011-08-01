#import <Cocoa/Cocoa.h>

@interface NSString (Base64)

- (NSString*)stringBase64Encoded ;
- (NSString*)stringBase64Decoded ;
- (NSData*)dataBase64Encoded ;
- (NSData*)dataBase64Decoded ;


+ (NSCharacterSet*)base64CharacterSet ;
	// This is actually 65 characters because it includes the filler "="

@end
