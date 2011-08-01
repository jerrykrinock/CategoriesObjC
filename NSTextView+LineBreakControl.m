

@implementation NSTextView (LineBreakControl)

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
	NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy] ;
	[paragraphStyle setLineBreakMode:lineBreakMode] ;		
	NSMutableDictionary* attributes = [[[self textStorage] attributesAtIndex:0
													  effectiveRange:NULL] mutableCopy] ;
	[attributes setObject:paragraphStyle
				   forKey:NSParagraphStyleAttributeName] ;
	[paragraphStyle release] ;
	NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:[self string]
																		   attributes:attributes] ;
	[attributes release] ;
	[[self textStorage] setAttributedString:attributedString] ;
	[attributedString release] ;
}

@end
