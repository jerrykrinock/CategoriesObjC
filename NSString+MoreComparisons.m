@implementation NSString (MoreComparisons)

+ (BOOL)isEqualHandlesNilString1:(NSString*)string1
						 string2:(NSString*)string2 {
	BOOL isEqual = YES ;
	if (string1) {
		if (!string2) {
			// Documentation for -isEqualToString does not state if
			// the argument can be nil, so for safety I handle that
			// here, without invoking it.
			isEqual = NO ;
		}
		else {
			isEqual = [string1 isEqualToString:string2] ;
		}
	}
	else if (string2) {
		// oldValue is nil but newValue is not
		isEqual = NO ;
	}
	
	return isEqual ;
}

@end
