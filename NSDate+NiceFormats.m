#import "NSDate+NiceFormats.h"
#import "NSString+SSYExtraUtils.h"

static NSDateFormatter* static_geekDateFormatter = nil;
static NSDateFormatter* static_geekMilliDateFormatter = nil;


#if (MAC_OS_X_VERSION_MAX_ALLOWED < 1060) 

/*!
@brief    Declares stuff defined in the 10.6 SDK,
to eliminate compiler warnings.

@details  Be careful to only invoke super on these methods after
you've checked that you are running under macOS 10.6.
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

+ (NSDateFormatter*)geekDateFormatter {
    if (!static_geekDateFormatter) {
        static_geekDateFormatter = [[NSDateFormatter alloc] init] ;
        [static_geekDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"] ;
    }

    return static_geekDateFormatter ;
}

+ (NSDateFormatter*)geekMilliDateFormatter {
    if (!static_geekMilliDateFormatter) {
        static_geekMilliDateFormatter = [[NSDateFormatter alloc] init] ;
        [static_geekMilliDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] ;
    }

    return static_geekMilliDateFormatter ;
}

- (NSString*)geekDateTimeString {
	return [[[self class] geekDateFormatter] stringFromDate:self] ;
}

- (NSString*)geekDateTimeStringMilli {
    return [[[self class] geekMilliDateFormatter] stringFromDate:self] ;
}

- (NSString*)hourMinuteSecond {
    return [[self geekDateTimeString] substringFromIndex:11] ;
}

- (NSString*)compactDateTimeString {
	//  Remove spaces, dashs and colons from YYYY-MM-DD HH:MM:SS
	NSString* s1 = [[self geekDateTimeString] stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" :-"]
																	withString:@""] ;
    return s1 ;
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
