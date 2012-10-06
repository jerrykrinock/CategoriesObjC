#import "NSString+TimeIntervals.h"
#import "NSString+LocalizeSSY.h"
#import "NSString+VarArgs.h"
#import "NSString+SSYExtraUtils.h"

#define FIVE_HUNDRED_YEARS (500*365.25*24*3600)

@implementation NSString (TimeIntervals)

+ (NSString*)stringWithUnitsForTimeInterval:(NSTimeInterval)interval
								   longForm:(BOOL)longForm {
	if (interval < -FIVE_HUNDRED_YEARS) {
		return @"Far Past" ;
	}
	if (interval > FIVE_HUNDRED_YEARS) {
		return @"Far Future" ;
	}
	
	
	NSString* unitsKey ;
	NSString* format ;
	CGFloat absoluteInterval = fabs(interval) ;
	if (absoluteInterval < 1.0) {
		unitsKey = @"timeIntSecsX" ;
		format = @"%5.3f" ;
	}
	else if (absoluteInterval < 60.0) {
		unitsKey = @"timeIntSecsX" ;
		format = @"%0.1f" ;
	}
	else if (absoluteInterval < 3600.0) {
		unitsKey = @"timeIntMinsX" ;
		interval /= 60.0 ;
		format = @"%0.0f" ;
	}
	else {
		unitsKey = @"timeIntHoursX" ;
		interval /= 3600.0 ;
		format = @"%0.1g" ;
	}
	
	if (!longForm) {
		unitsKey = [unitsKey stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"X"]
												   withString:@"AbbrX"] ;
	}
	
	NSString* numberString = [NSString stringWithFormat:format, interval] ;
	return [NSString localizeFormat:
			unitsKey,
			numberString] ;
}

@end
