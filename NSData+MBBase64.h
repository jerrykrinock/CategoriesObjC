#import <Cocoa/Cocoa.h>

/* Code written by Milo, aka MiloBird, http://www.milobird.com/blog/
 was copied from http://www.cocoadev.com/index.pl?BaseSixtyFour
 */

@interface NSData (MBBase64)

+ (id)dataByDecodingBase64String:(NSString *)string;
//  Padding '=' characters are optional. Whitespace is ignored.

- (NSString *)stringEncodedBase64 ;

@end
