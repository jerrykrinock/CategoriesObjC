@implementation NSPopUpButton (Populating)

- (void)populateTitles:(NSArray*)titles
				target:(id)target
				action:(SEL)action {
	[self removeAllItems] ;
	
	NSMenu* menu = [self menu] ;
	[self setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]] ;
	NSMenuItem* menuItem ;
	NSInteger i = 0 ;
	NSEnumerator * e = [titles objectEnumerator] ;
	NSString* title ;
	while ((title = [e nextObject])) {
		menuItem = [menu insertItemWithTitle:title
									  action:action
							   keyEquivalent:@""
									 atIndex:i ] ;
		[menuItem setTarget:target] ;
		[menuItem setTag:i++] ;
	}
}

// Because this category is also used in Bookdog,
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)		

- (void)tagItemsAsPositioned {
	NSInteger i=0 ;
	for(NSMenuItem* item in [self itemArray]) {
		[item setTag:i++] ;
	}
}

#endif

#
@end