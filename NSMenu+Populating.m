

/*
 If you are developing with the 10.5 SDK, MAC_OS_X_VERSION_MAX_ALLOWED = 1050, MAC_OS_X_VERSION_10_5 = 1050 and the following #if will be true.
 If you are developing with the 10.6 SDK, MAC_OS_X_VERSION_MAX_ALLOWED = 1060, MAC_OS_X_VERSION_10_5 = 1050 and the following #if will be false.
*/
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5) 

@implementation  NSMenu (Populating) 

- (void)removeAllItems {
	NSArray* items = [self itemArray] ;
	int i ;
	int N = [items count] ;
	for (i=N-1; i>=0; i--) {
		[self removeItemAtIndex:i] ;
	}
}

@end

#endif