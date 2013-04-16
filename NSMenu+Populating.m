#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1060) 

@implementation  NSMenu (Populating) 

- (void)removeAllItems {
	NSArray* items = [self itemArray] ;
	NSInteger i ;
	NSInteger N = [items count] ;
	for (i=N-1; i>=0; i--) {
		[self removeItemAtIndex:i] ;
	}
}

@end

#endif