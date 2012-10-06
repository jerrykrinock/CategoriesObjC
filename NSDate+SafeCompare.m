#define NSDateIsLaterThan NSOrderedDescending
#define NSDateIsEarlierThan NSOrderedAscending

@implementation NSDate (SafeCompare)

+ (NSDate*)laterDate:(NSDate*)date1
				date:(NSDate*)date2 {
	NSDate* laterDate ;
	if (date1 != nil) {
		if (date2 != nil) {
			laterDate = [date1 laterDate:date2] ;
		}
		else {
			laterDate = date1 ;
		}
	}
	else {
		laterDate = date2 ;
	}
	
	return laterDate ;
}

+ (BOOL)isEqualHandlesNilDate1:(NSDate*)date1
                         date2:(NSDate*)date2
                     tolerance:(NSTimeInterval)tolerance {
	BOOL isEqual = NO ;
	if (date1) {
		if (!date2) {
			// Documentation for -isEqual does not state if
			// the argument can be nil, so for safety I handle that
			// here, without invoking it.
            
			// date2 is nil but object1 is not
			// Leave isEqual as initialized, to NO.
		}
		else {
            if (tolerance == 0.0) {
                isEqual = [date1 isEqual:date2] ;
            }
            else {
                NSTimeInterval t1 = [date1 timeIntervalSinceReferenceDate] ;
                NSTimeInterval t2 = [date2 timeIntervalSinceReferenceDate] ;
                NSTimeInterval diff = fabs(t2 - t1) ;
                isEqual = diff <= tolerance ;
            }
		}
	}
	else if (date2) {
		// object1 is nil but object2 is not
		// Leave isEqual as initialized, to NO.
	}
	else {
		isEqual = YES ;
	}
	
	return isEqual ;
}

@end
