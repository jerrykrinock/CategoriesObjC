#import <Cocoa/Cocoa.h>

@interface NSData (Base64)

- (NSData*)dataBase64Encoded ;
- (NSData*)dataBase64Decoded ;
- (NSString*)stringBase64Encoded ;
- (NSString*)stringBase64Decoded ;

@end

