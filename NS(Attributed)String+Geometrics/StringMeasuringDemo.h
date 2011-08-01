#import <Cocoa/Cocoa.h>
#import "NSView+GreenArrows.h"

@interface StringMeasuringDemo : NSObject {
	IBOutlet NSTextView* textView ;
	IBOutlet NSView* placeholderView ;
	IBOutlet NSTextField* heightOfTextView ;
	IBOutlet NSTextField* heightOfTextField ;
	IBOutlet NSTextField* textFieldFontReadout ;
	
	NSTextField* _textField ;
	
	NSAttributedString* _attributedString ;
}

- (NSAttributedString *)attributedString;
- (void)setAttributedString:(NSAttributedString *)value;

- (float)windowWidth;
- (void)setWindowWidth:(float)width ;

- (float)windowHeight;
- (void)setWindowHeight:(float)height ;

- (IBAction)setStringReadMe:(id)sender ;
- (IBAction)setStringOutline:(id)sender ;

@end
