#import "NSDate+NiceFormats.h"
#import "NSString+SSYExtraUtils.h"

#if (MAC_OS_X_VERSION_MAX_ALLOWED < 1060) 

/*!
@brief    Declares stuff defined in the 10.6 SDK,
to eliminate compiler warnings.

@details  Be careful to only invoke super on these methods after
you've checked that you are running under Mac OS X 10.6.
*/
@interface NSDate (DefinedInMac_OS_X_10_6)

- (id)dateByAddingTimeInterval:(NSTimeInterval)seconds ;

@end

#endif

@implementation NSDate (NiceFormats)

- (NSString*)medDateShortTimeString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle] ;
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle] ;		
	NSString* string  = [dateFormatter stringFromDate:self];
	[dateFormatter release] ;
	
	return string ;
}

- (NSString*)geekDateTimeString {
	// After spending 45 minutes reading NSDateFormatter trying to 
	// figure out a non-depracated and supported way to get a date
	// in geek format, I noticed that -[NSDate description] is
	// *documented* to return a string in this format:
	//     YYYY-MM-DD HH:MM:SS ±HHMM
	// Prior to Mac OS 10.7, ±HHMM = the local time zone offset
	// Starting in Mac OS 10.7, ±HHMM = +0000.
	// We want the time in the local time zone, so we need to read and adjust if necessary
	NSString* s = [self description] ;
	NSInteger tzSign = [[s substringWithRange:NSMakeRange(20,1)] isEqualToString:@"+"] ? +1 : -1 ;
	NSInteger tzHours = [[s substringWithRange:NSMakeRange(21,2)] integerValue] ;
	NSInteger tzMinutes = [[s substringWithRange:NSMakeRange(23,2)] integerValue] ;
	NSInteger tzSeconds = tzSign * (3600*tzHours + 60*tzMinutes) ; 
	NSInteger localTzSeconds = [[NSTimeZone localTimeZone] secondsFromGMT] ;
	NSString* localTimeString ;
	if (tzSeconds == localTzSeconds) {
		// This must be Mac OS 10.5 or 10.6.
		localTimeString = s ;
	}
	else {
		// This must be Mac OS 10.7.
		// Fortunately, starting in Mac OS 10.6 we have -[NSDate dateByAddingTimeInterval]
		NSDate* localDate = [self dateByAddingTimeInterval:(localTzSeconds - tzSeconds)] ;
		localTimeString = [localDate description] ;
	}
	
	NSString* answer = [localTimeString substringToIndex:19] ;
	
	return answer ;
}

- (NSString*)geekDateTimeStringMilli {
	NSString* formatString = @"yyyy-MM-dd HH:mm:ss.SSS" ;
	
	NSDateFormatter* formatter ;
	formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:formatString];
	
	NSString* dateString = [formatter stringFromDate:self] ;	

	[formatter release] ;
	
	return dateString ;
}

- (NSString*)compactDateTimeString {
	//  Remove spaces, dash and colon from YYYY-MM-DD HH:MM:SS
	NSString* s1 = [[self geekDateTimeString] stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" :-"]
																	withString:@""] ;
	// Time zone
	NSString* tz = [[self description] substringFromIndex:20] ;
	return [s1 stringByAppendingString:tz] ;
}

+ (NSString*)currentDateFormattedConcisely {	
	return [[NSDate date] medDateShortTimeString] ;
}

/*
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
[dateFormatter setDateFormat:@"ss.SSSS"];
NSDate *date = [NSDate date];	
NSString* secondsWithMilliseconds = [dateFormatter stringFromDate:date];
[dateFormatter release] ;
*/

@end