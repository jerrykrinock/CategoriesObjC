#import <Cocoa/Cocoa.h>


@interface NSString (OAuth) 

- (NSString*)HMACSHA1SignatureWithSecret:(NSString *)secret ;

+ stringOAuthWithQueryDictionary:(NSDictionary*)dictionary ;

- (NSString*)stringByPercentEscapeEncodingForOAuth ;

@end

