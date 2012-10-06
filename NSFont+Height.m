#import "NSFont+Height.h"

@implementation NSFont (Height) 

- (CGFloat)tableRowHeight {
	NSLayoutManager* lm = [[NSLayoutManager alloc] init] ;
	CGFloat dlhff = [lm defaultLineHeightForFont:self] ;
	[lm release] ;
	return dlhff + 1.0 ;
}


@end
