#import "NSMenu+Ancestry.h"

@implementation NSMenu (Ancestry)

- (NSMenuItem*)supermenuItem {
	NSMenu* supermenu = [self supermenu] ;
	NSArray* items = [supermenu itemArray] ;
	NSMenuItem* supermenuItem = nil ;
	for (NSMenuItem* item in items) {
		if ([item submenu] == self) {
			supermenuItem = item ;
			break ;
		}
	}
	
	return supermenuItem ;
}

- (NSInteger)supertag {
	NSMenuItem* supermenuItem = [self supermenuItem] ;
	if (supermenuItem) {
		return [supermenuItem tag] ;
	}
	
	return NSNotFound ;
}

@end