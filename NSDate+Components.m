#import "NSDate+Components.h"

@implementation NSDate (Components)

+ (NSDate*)dateWithYear:(NSInteger)year
				  month:(NSInteger)month
					day:(NSInteger)day
				   hour:(NSInteger)hour
				 minute:(NSInteger)minute
				 second:(NSInteger)second
		 timeZoneOffset:(NSInteger)timeZoneOffset {
	// Get current date in the international format YYYY-MM-DD HH:MM:SS ±HHMM
	NSMutableString* dateString = [[[NSDate date] descriptionWithCalendarFormat:nil
															   timeZone:nil
																 locale:nil] mutableCopy] ;
	NSString* substitution ;

	if (year != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%04ld", (long)year] ;
		[dateString replaceCharactersInRange:NSMakeRange(0,4)
								  withString:substitution] ;
	}
	if (month != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02ld", (long)month] ;
		[dateString replaceCharactersInRange:NSMakeRange(5,2)
								  withString:substitution] ;
	}
	if (day != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02ld", (long)day] ;
		[dateString replaceCharactersInRange:NSMakeRange(8,2)
								  withString:substitution] ;
	}
	if (hour != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02ld", (long)hour] ;
		[dateString replaceCharactersInRange:NSMakeRange(11,2)
								  withString:substitution] ;
	}
	if (minute != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02ld", (long)minute] ;
		[dateString replaceCharactersInRange:NSMakeRange(14,2)
								  withString:substitution] ;
	}
	if (second != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02ld", (long)second] ;
		[dateString replaceCharactersInRange:NSMakeRange(17,2)
								  withString:substitution] ;
	}
	if (timeZoneOffset != NSNotFound) {
		unichar timeZoneSign = (timeZoneOffset > 0) ? '+': '-' ;
		NSInteger timeZoneMagnitude = abs((int)timeZoneOffset) ;
		NSInteger timeZoneHours = timeZoneMagnitude/3600 ;
		NSInteger timeZoneMinutes = (timeZoneMagnitude - 3600*timeZoneHours)/60 ;
		substitution = [NSString stringWithFormat:@"%c%02ld%02ld",
						timeZoneSign,
						(long)timeZoneHours,
						(long)timeZoneMinutes] ;
		[dateString replaceCharactersInRange:NSMakeRange(20,5)
								  withString:substitution] ;
	}
	
	// Create from the mutated string a new date
	NSDate* date = [NSDate dateWithString:dateString] ;
	[dateString release] ;
	
	return date ;
}

- (NSString*)yearString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy"];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}


- (NSString*)monthStringWithLeadingZero:(BOOL)leadingZero {
    NSString* formatString = leadingZero ? @"MM" : @"M" ;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formatString];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}

- (NSString*)monthString {
    return [self monthStringWithLeadingZero:YES] ;
}

- (NSString*)monthStringWithoutLeadingZero {
    return [self monthStringWithLeadingZero:NO] ;
}

- (NSString*)dayStringWithLeadingZero:(BOOL)leadingZero {
    NSString* formatString = leadingZero ? @"dd" : @"d" ;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formatString];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}

- (NSString*)dayString {
    return [self dayStringWithLeadingZero:YES] ;
}

- (NSString*)dayStringWithoutLeadingZero {
    return [self dayStringWithLeadingZero:NO] ;
}

- (NSString*)hourString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH"];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}



- (NSString*)minuteString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"mm"];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}



- (NSString*)secondString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"ss"];
	NSString* string = [dateFormatter stringFromDate:self] ;
	[dateFormatter release] ;
	return string ;
}



- (NSString*)timeZoneOffsetString {
	return [self descriptionWithCalendarFormat:@"%z"
									  timeZone:nil
										locale:nil] ;
}

- (NSInteger)year {
	return [[self yearString] integerValue] ;
}


- (NSInteger)month {
	return [[self monthString] integerValue] ;
}


- (NSInteger)day {
	return [[self dayString] integerValue] ;
}


- (NSInteger)hour {
	return [[self hourString] integerValue] ;
}


- (NSInteger)minute {
	return [[self minuteString] integerValue] ;
}


- (NSInteger)second {
	return [[self secondString] integerValue] ;
}

// Todo: Change *all* of the above methods to use NSDateFormatter, like -minutesString does.
// (This is the method now recommended by Apple.)
// This date format shows how to get time with milliseconds:
// @"yyyy-MM-dd HH:mm:ss.SSS"];
// For more format specifiers:
// http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns


@end