#import "NSMenuItem+Font.h"

@implementation NSMenuItem (Font)

- (void)setFontColor:(NSColor*)color
				size:(CGFloat)size {
	// Documentation for -menuOfFontSize: says that nil is supposed to give default
	// menu font size, but it gives 13 instead of 14.  So, I hard-code 14.0.
	if (size == 0) {
		size = 14.0 ;
	}
	NSFont* font = [NSFont menuFontOfSize:size] ;
	NSString* title = [self title] ;
	NSDictionary* fontAttribute = [NSDictionary dictionaryWithObjectsAndKeys:
								   font, NSFontAttributeName,
								   nil] ;				
	NSMutableAttributedString* newTitle = [[NSMutableAttributedString alloc] initWithString:title
																				 attributes:fontAttribute] ;
	if (color) {
		NSDictionary* moreAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										color, NSForegroundColorAttributeName,
										nil] ;				
		NSRange range = NSMakeRange(0, [title length]) ;
		[newTitle addAttributes:moreAttributes
						  range:range] ;
	}

	[self setAttributedTitle:newTitle] ;
	[newTitle release] ;
}

@end