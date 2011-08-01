#import "NSDate+LongLong1970.h"


@implementation NSDate (LongLong1970) 

+ (NSDate*)dateWithLongLongMicrosecondsSince1970:(NSNumber*)value {
	NSDate* date = nil ;
	if ([value respondsToSelector:@selector(longLongValue)]) {
		long long microseconds1970 = [value longLongValue] ;
		NSTimeInterval seconds1970 = microseconds1970/1000000.0 ;
		date = [NSDate dateWithTimeIntervalSince1970:seconds1970] ;
	}
	
	return date ;
}

- (NSNumber*)longLongMicrosecondsSince1970 {
	NSTimeInterval seconds1970 = [self timeIntervalSince1970] ;
	long long microseconds1970 = seconds1970 * 1000000 ;
	return [NSNumber numberWithLongLong:microseconds1970] ;
}

+ (NSNumber*)longLongMicrosecondsSince1970 {
	return [[NSDate date] longLongMicrosecondsSince1970] ;
}

@end

