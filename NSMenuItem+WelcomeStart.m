#import "NSString+LocalizeSSY.h"
#import "BkmxBasis+Strings.h"

@implementation NSMenuItem (WelcomeStart)

- (void)addWelcomeStartHere {
	// Documentation for -menuOfFontSize says that nil is supposed to give default
	// menu font size, but it gives 13 instead of 14.  So, I hard-code 14.0.
	NSFont* font = [NSFont menuFontOfSize:14.0] ;
	NSString* rawTitle = [self title] ;
	NSString* highlightedText = [NSString stringWithFormat:@"%@  %@%C",
								 [[BkmxBasis sharedBasis] labelWelcome],
								 [NSString localize:@"startHere"],
								 0x2026] ;
	NSString* spacing = @"        " ;
	NSString* newTitleText = [NSString stringWithFormat:@"%@%@%@",
							  rawTitle,
							  spacing,
							  highlightedText] ;
	NSDictionary* fontAttribute = [NSDictionary dictionaryWithObjectsAndKeys:
								   font, NSFontAttributeName,
								   nil] ;				
	NSMutableAttributedString* newTitle = [[NSMutableAttributedString alloc] initWithString:newTitleText
																				 attributes:fontAttribute] ;
	NSRange highlightedRange = NSMakeRange([rawTitle length] + [spacing length], [highlightedText length]) ;
	NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										 [NSColor blueColor], NSForegroundColorAttributeName,
										 nil] ;				
	[newTitle addAttributes:highlightAttributes
					  range:highlightedRange] ;
	[self setAttributedTitle:newTitle] ;
	[newTitle release] ;
}

@end
