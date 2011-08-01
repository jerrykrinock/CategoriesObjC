#import "NSDate+Microsoft1601Epoch.h"

NSTimeInterval const constIntMicrosecondsPerSecond = 1e6 ;

/* I got this constant from here:
 http://stackoverflow.com/questions/611816/what-does-windows-filetime-contain-trying-to-convert-to-a-php-date-time
 A rounded-off version is here:
 http://blogs.msdn.com/brada/archive/2004/03/20/93332.aspx
 Note that it's a little more than converting 369 years to
 seconds using Calculator.app.  Probably due to leap years, etc.
 But this constant is not used at this time.  See next one!
 */
#define MICROSOFT_TICKS_FROM_1601_TO_1970 116444735995904000

/*
 To further add to the confusion, Google Chrome uses microseconds
 instead of Microsoft ticks, so this constant is the former
 divided by 10.
 */
#define MICROSECONDS_FROM_1601_TO_1970     11644473599590400

@implementation NSDate (Microsoft1601Epoch) 

+ (NSDate*)dateWithMicrosecondsSince1601:(long long)microseconds {
	microseconds -= MICROSECONDS_FROM_1601_TO_1970 ;
	NSTimeInterval timeInterval = microseconds/constIntMicrosecondsPerSecond ;
	return [NSDate dateWithTimeIntervalSince1970:timeInterval] ;
}

- (long long)microsecondsSince1601 {
	return constIntMicrosecondsPerSecond *[self timeIntervalSince1970] + MICROSECONDS_FROM_1601_TO_1970 ;
}

@end
