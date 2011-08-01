#import <Cocoa/Cocoa.h>

extern NSTimeInterval const constIntMSWindowsTicksPerSecond ;

@interface NSDate (Microsoft1601Epoch)

+ (NSDate*)dateWithMicrosecondsSince1601:(long long)ticks ;

- (long long)microsecondsSince1601  ;

@end
