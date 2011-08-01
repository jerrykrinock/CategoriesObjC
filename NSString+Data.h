#import <Cocoa/Cocoa.h>

@interface NSString (Data)

// Convenience methods that Apple should have provided

+ (NSString*)stringWithData:(NSData*)data
				   encoding:(NSStringEncoding)encoding ;

+ (NSString*)stringWithDataUTF8:(NSData*)data ;

@end
