#import <Cocoa/Cocoa.h>


/* Configuring an NSTextView in an NSScrollView for horizontal scrolling,
   vertical scrolling, or both is so complicated that when I figured it out
   I decided to write a category for it.  No more trial-and-error with
   stupid checkboxes in Interface Builder!!
 
   For this to work, the NSTextView must be enclosed in an NSScrollView,
   with an invisible NSLayoutManager, NSText, NSTextStorage etc.
   This is the way it comes off the Library Palette in Interface Builder 3.
 
   Has only been tested with horizontal=YES and vertical=YES so far.
*/


@interface NSTextView (Configurations) 

- (void)configureScrollingHorizontal:(BOOL)horizontal
							vertical:(BOOL)vertical ;

@end
