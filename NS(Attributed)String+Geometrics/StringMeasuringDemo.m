#import "StringMeasuringDemo.h"
#import "NS(Attributed)String+Geometrics.h"

@interface NSLayoutManager (extra)
- (id)myExtraData;
@end

@implementation NSLayoutManager (extra)
- (id)myExtraData;
{
    return self->_extraData;
}
@end

@implementation StringMeasuringDemo

+ (void)initialize {
    [self setKeys:[NSArray arrayWithObjects:@"attributedString",nil]
triggerChangeNotificationsForDependentKey:@"windowWidth"];

    [self setKeys:[NSArray arrayWithObjects:@"attributedString",nil]
triggerChangeNotificationsForDependentKey:@"windowHeight"];
}

- (NSAttributedString *)attributedString {
    return [[_attributedString retain] autorelease];
}

- (void)setAttributedString:(NSAttributedString *)value {
	if (_attributedString != value) {
        [_attributedString release];
        _attributedString = [value copy];
    }
}

- (NSString*)string {
	return [[self attributedString] string] ;
}

- (void)setString:(NSString*)string {
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   [textView font], NSFontAttributeName,
						   nil] ;
    NSAttributedString* as = [[NSAttributedString alloc] initWithString:string
															 attributes:attrs] ;
	[self setAttributedString:as] ;
    [as release] ;
}

- (float)refreshTextHeights {
	[textView setSelectedRange:NSMakeRange(0,0)] ;
	
    // Here is where we actually invoke NS(Attributed)String+Geometrics
	float answer ;
	NSAttributedString* attributedString = [self attributedString] ;
	NSString* string = [attributedString string] ;
	if (string == nil) {
		string = @"" ;
	}
	
	// Measure contents of the Text View
	answer = [attributedString heightForWidth:[textView frame].size.width] ;	
	[textView showGreenArrowsWithHeight:answer] ;
	[heightOfTextView setStringValue:[NSString stringWithFormat:@"Calculated Height: %0.1f pts", answer]] ;
	
	// Set font of text field by copying the initial font in the text view 
	NSFont* font = [attributedString attribute:NSFontAttributeName
											  atIndex:0
									   effectiveRange:NULL] ;

	NSString* fontDescription ;
	if (font != nil) {
		[_textField setFont:font] ;
		fontDescription = [[_textField font] description] ;
	}
	else {
		fontDescription = @"nil ('View: Helvetica 12.  'Field: Lucida Grande 12.)" ;
	}		
	[textFieldFontReadout setStringValue:fontDescription] ;

	[_textField setStringValue:string] ;
	
	// Measure contents of the Text Field
	gNSStringGeometricsTypesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility ;
	answer = [[self string] heightForWidth:[_textField frame].size.width
									  font:[_textField font]] ;	
	gNSStringGeometricsTypesetterBehavior = NSTypesetterLatestBehavior ;
	[_textField showGreenArrowsWithHeight:answer] ;
	[heightOfTextField setStringValue:[NSString stringWithFormat:@"Calculated Height: %0.1f pts", answer]] ;

    return answer ;
}

- (void)observeSize {
	[self setAttributedString:[self attributedString]] ;
	[self refreshTextHeights] ;
}

- (IBAction)setStringReadMe:(id)sender {
	NSString* s = @"To cause recalculation of sizes, resize the window.\n\nYou can change the font by typing cmd+T, selecting text in the NSTextView, etc.\n\nAfter you resize the window, the string in the 'Field will be set to the same as in the 'View, and the (uniform) font of the 'Field will be set to that found in the first attribute run of the 'View.  However, initially they are both nil fonts, which is Hevetica 12 for the 'View and Lucida Grande 12 for the 'Field.\n\nSome descenders: ygpqj)" ;
	[self setString:s] ;
}

- (IBAction)setStringOutline:(id)sender {
	NSMutableString* s = [NSMutableString string] ;
	int nLines = 9 ;
	int i ;
	for (i=0; i<nLines; i++) {
		if (i>0) {
			[s appendString:@"\n"] ;
		}
		int j ;
		for (j=0; j<i; j++) {
			[s appendString:@"   "] ;
		}
		if (i>0) {
				for (j=0; j<i; j++) {
				[s appendString:@"Sub"] ;
			}
		}

		[s appendFormat:@"Heading %i", i] ;
	}
	[self setString:s] ;
}

- (float)windowWidth {
	NSWindow* window = [textView window] ;
	NSRect frame = [window frame] ;
	return frame.size.width ;
}

- (void)setWindowWidth:(float)width {
	NSWindow* window = [textView window] ;
	NSRect frame = [window frame] ;
	frame.size.width = width ;
	[window setFrame:frame display:YES] ;
}

- (float)windowHeight {
	NSWindow* window = [textView window] ;
	NSRect frame = [window frame] ;
	return frame.size.height ;
}

- (void)setWindowHeight:(float)height {
	NSWindow* window = [textView window] ;
	NSRect frame = [window frame] ;
	frame.size.height = height ;
	[window setFrame:frame display:YES] ;
}


- (void)awakeFromNib {
	// Want two lines for textFieldFontReadout but stupid Interface Builder
	// doesn't allow it to be set to more than one line.
	NSRect frame ;
	
	frame = [textFieldFontReadout frame] ;
	float lineHeight = frame.size.height ;
	frame.origin.y -= lineHeight ;
	frame.size.height += lineHeight ;
	[textFieldFontReadout setFrame:frame] ;
	[[textFieldFontReadout cell] setWraps:YES];
	if ([[textFieldFontReadout cell] respondsToSelector:@selector(setLineBreakMode:)]) {  // 10.3 does not
		[[textFieldFontReadout cell] setLineBreakMode:NSLineBreakByWordWrapping];
	}
	[self setStringReadMe:self] ;

	// Steal attributes from placeholderView
	int autoresizingMask = [placeholderView autoresizingMask] ;
	frame = [placeholderView frame] ;
	NSView* superview = [placeholderView superview] ;
	
	// Create new _textField
	_textField = [[NSTextField alloc] initWithFrame:frame] ;
	[[_textField cell] setWraps:YES];
	if ([[_textField cell] respondsToSelector:@selector(setLineBreakMode:)]) {  // 10.3 does not
		[[_textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
	}
	[_textField setAutoresizingMask:autoresizingMask] ;
	[_textField bind:@"stringValue"
			toObject:self
		 withKeyPath:@"string"
			 options:nil] ;
	
	// Replace placeholder with _textField
	[placeholderView removeFromSuperviewWithoutNeedingDisplay] ;
	[superview addSubview:_textField] ;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(observeSize)
											     name:NSWindowDidResizeNotification
											   object:nil] ;
	[self refreshTextHeights] ;
}

@end
