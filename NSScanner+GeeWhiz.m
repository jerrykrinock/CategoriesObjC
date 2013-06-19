@implementation NSScanner (GeeWhiz)

- (BOOL)tryScanPastString:(NSString*)target {
	BOOL foundTarget = NO ;
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)		
	NSUInteger startLoc = [self scanLocation] ;
#else
	NSUInteger startLoc = [self scanLocation] ;
#endif
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


