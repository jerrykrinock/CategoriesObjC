

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
		substitution = [NSString stringWithFormat:@"%04d", year] ;
		[dateString replaceCharactersInRange:NSMakeRange(0,4)
								  withString:substitution] ;
	}
	if (month != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02d", month] ;
		[dateString replaceCharactersInRange:NSMakeRange(5,2)
								  withString:substitution] ;
	}
	if (day != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02d", day] ;
		[dateString replaceCharactersInRange:NSMakeRange(8,2)
								  withString:substitution] ;
	}
	if (hour != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02d", hour] ;
		[dateString replaceCharactersInRange:NSMakeRange(11,2)
								  withString:substitution] ;
	}
	if (minute != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02d", minute] ;
		[dateString replaceCharactersInRange:NSMakeRange(14,2)
								  withString:substitution] ;
	}
	if (second != NSNotFound) {
		substitution = [NSString stringWithFormat:@"%02d", second] ;
		[dateString replaceCharactersInRange:NSMakeRange(17,2)
								  withString:substitution] ;
	}
	if (timeZoneOffset != NSNotFound) {
		unichar timeZoneSign = (timeZoneOffset > 0) ? '+': '-' ;
		NSInteger timeZoneMagnitude = abs(timeZoneOffset) ;
		NSInteger timeZoneHours = timeZoneMagnitude/3600 ;
		NSInteger timeZoneMinutes = (timeZoneMagnitude - 3600*timeZoneHours)/60 ;
		substitution = [NSString stringWithFormat:@"%c%02d%02d",
						timeZoneSign,
						timeZoneHours,
						timeZoneMinutes] ;
		[dateString replaceCharactersInRange:NSMakeRange(20,5)
								  withString:substitution] ;
	}
	
	// Create from the mutated string a new date
	NSDate* date = [NSDate dateWithString:dateString] ;
	[dateString release] ;
	
	return date ;
}

- (NSString*)yearString {
	return [self descriptionWithCalendarFormat:@"%Y"
									  timeZone:nil
										locale:nil] ;
}


- (NSString*)monthString {
	return [self descriptionWithCalendarFormat:@"%m"
									  timeZone:nil
										locale:nil] ;
}



- (NSString*)dayString {
	return [self descriptionWithCalendarFormat:@"%d"
									  timeZone:nil
										locale:nil] ;
}



- (NSString*)hourString {
	return [self descriptionWithCalendarFormat:@"%H"
									  timeZone:nil
										locale:nil] ;
}



- (NSString*)minuteString {
	return [self descriptionWithCalendarFormat:@"%M"
									  timeZone:nil
										locale:nil] ;
}



- (NSString*)secondString {
	return [self descriptionWithCalendarFormat:@"%S"
									  timeZone:nil
										locale:nil] ;
}



- (NSString*)timeZoneOffsetString {
	return [self descriptionWithCalendarFormat:@"%z"
									  timeZone:nil
										locale:nil] ;
}

- (NSInteger)year {
	return [[self yearString] intValue] ;
}


- (NSInteger)month {
	return [[self monthString] intValue] ;
}


- (NSInteger)day {
	return [[self dayString] intValue] ;
}


- (NSInteger)hour {
	return [[self hourString] intValue] ;
}


- (NSInteger)minute {
	return [[self minuteString] intValue] ;
}


- (NSInteger)second {
	return [[self secondString] intValue] ;
}




@end