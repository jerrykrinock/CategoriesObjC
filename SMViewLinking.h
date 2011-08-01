//Vertically-Expanding NSTextField
//
//http://www.cocoabuilder.com/archive/message/cocoa/2006/6/18/165893
//
//I was reading this thread because I was looking for a solution for  
//many views to rearrange in interaction to each other. For example,  
//one textfields gets bigger because the user types in something and  
//two other textfields below move downwards accordingly to make room  
//for it.
//
//Thank you for your code on cocoadev, it was very helpful to write the  
//automatically expanding textfield! But still I couldn't get other  
//views to react and move around (which of course wasn't your goal at  
//								all).
//
//So I wrote this protocol to define a system with the following  
//behaviour: "if a view changes frame, it will rearrange other views to  
//maintain defined distances between the borders".
//
//The implementation works quite nicely. HOWEVER, this code is veeeery  
//ruff and newbieish, not very well tested and most probably not very  
//elegant. I decided to post it anyway for those who like it and  
//especially for those who don't like it and maybe would like to  
//improve it. I apologize for the code length! As I said, it still  
//lacks elegancy and needs improvement.
//
//If someone thinks, that this should go into another or it's own  
//thread, please let me know!
//
//Thanks!
//Sebastian Morsch
//



//  START OF SMViewLinking.h

//  protocol that views can adopt to maintain their layout as it was defined in IB.
//  one view (source view) can 'link' one of its four graphical borders (= fix the distance) to those of other
//  views (destination views), and those destination views will be moved/resized if the
//  source view changes.
//  if the destination views are source views themselves, the linked destiantion views
//  resize, too. this of course, is the big weakness of this system, because...:
//
//  WARNING: you have to avoid 'linkining feedbacks' where subviews are stiffly linked
//  with their superviews in a closed loop. this conflicts with the standard autoresizing!


#import <Cocoa/Cocoa.h>


// constants
typedef enum {
	SMViewLinkingTopBorderType = 1,
	SMViewLinkingBottomBorderType = 2,
	SMViewLinkingLeftBorderType = 4,
	SMViewLinkingRightBorderType = 8
} SMViewLinkingBorderType;

typedef enum {
	SMViewLinkingResizesHorizontally = 1,
	SMViewLinkingResizesVertically = 2,
	SMViewLinkingConstrainedToMinWidth = 4,
	SMViewLinkingConstrainedToMinHeight = 8,
	SMViewLinkingConstrainedToMaxWidth = 16,
	SMViewLinkingConstrainedToMaxHeight = 32,
} SMViewLinkingLinkedResizingMask;

extern NSString *SMViewLinkingDestViewKeyName;
extern NSString *SMViewLinkingSourceBorderKeyName;
extern NSString *SMViewLinkingDestBorderKeyName;
extern NSString *SMViewLinkingDistanceKeyName;


- (void)linkBorder:(SMViewLinkingBorderType)sourceBorder toView: 
	(NSView *)destView
			border:(SMViewLinkingBorderType)destBorder;
- (void)unlinkView:(NSView *)destView;
- (void)moveLinkedBorder:(SMViewLinkingBorderType)border by:(float) 
	offset;
- (SMViewLinkingLinkedResizingMask)linkedResizingMask;
- (void)setLinkedResizingMask:(SMViewLinkingLinkedResizingMask)mask;
- (NSSize)linkedMinSize;
- (void)setLinkedMinSize:(NSSize)minSize;
- (NSSize)linkedMaxSize;
- (void)setLinkedMaxSize:(NSSize)maxSize;
@end


// helper function
float SMViewLinkingBorderPosition(NSRect frame,  
								  SMViewLinkingBorderType border)
{
	if (border == SMViewLinkingTopBorderType) {return (frame.origin.y +  
													   frame.size.height);}
	if (border == SMViewLinkingBottomBorderType) {return (frame.origin.y);}
	if (border == SMViewLinkingLeftBorderType) {return (frame.origin.x);}
	if (border == SMViewLinkingRightBorderType) {return (frame.origin.x  
														 + frame.size.width);}
	return 0.0;
}
