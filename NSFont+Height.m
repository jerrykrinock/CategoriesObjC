#import "NSFont+Height.h"

@implementation NSFont (Height) 

- (float)tableRowHeight {
	NSLayoutManager* lm = [[NSLayoutManager alloc] init] ;
	float dlhff = [lm defaultLineHeightForFont:self] ;
	[lm release] ;
	return dlhff + 1.0 ;
}


@end
