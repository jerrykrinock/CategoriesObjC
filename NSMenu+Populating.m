

#if (MAC_OS_X_VERSION_MAX_ALLOWED < 1060) 

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