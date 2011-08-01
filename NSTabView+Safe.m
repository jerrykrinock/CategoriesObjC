#import "NSTabView+Safe.h"


@implementation NSTabView (Safe)

- (void)selectTabViewItemSafelyWithIdentifier:(NSString*)identifier {
	NSInteger index = [self indexOfTabViewItemWithIdentifier:identifier] ;
	if (index != NSNotFound) {
		[self selectTabViewItemAtIndex:index] ;
	}
}

@end
