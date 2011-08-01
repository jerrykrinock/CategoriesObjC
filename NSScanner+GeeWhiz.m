#import "NSScanner+GeeWhiz.h"

@implementation NSScanner (GeeWhiz)

- (BOOL)tryScanPastString:(NSString*)target {
	BOOL foundTarget = NO ;
	int unsigned startLoc = [self scanLocation] ;
	[self scanUpToString:target intoString:NULL] ;
	if ([self scanString:target intoString:NULL]) {
		foundTarget = YES ;
	}
	else {
		[self setScanLocation:startLoc] ;
	}
	
	return foundTarget ;
}

- (BOOL)scanUpToAndThenLeapOverString:(NSString*)stopString intoString:(NSString**)stringValue {
	[self scanUpToString:stopString
			  intoString:stringValue] ;
	// Note that we ignore the result of the above, which will be NO if the scanner
	// was initially at end or parked at beginning of stopString and YES otherwise.
	// That's a rather useless and confusing result.
	BOOL result = [self scanString:stopString intoString:NULL] ;
	
	return result ;
}

@end


