#import "SMLinkedView.h"


// private methods
@interface SMLinkedView (private)
- (void)_updateLinkedViews;
- (void)_moveBorder:(SMViewLinkingBorderType)border ofView:(NSView *) 
			view by:(CGFloat)offset;
@end


@implementation SMLinkedView

- (id)initWithFrame:(NSRect)frameRect
{
	if (self == [super initWithFrame:frameRect]) {
		linkedViews = [[NSMutableArray alloc] initWithCapacity:0];
		linkedResizingMask = 0;
		linkedMinSize = NSMakeSize(0.0, 0.0);
		linkedMaxSize = NSMakeSize(0.0, 0.0);
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self == [super initWithCoder:decoder]) {
		linkedViews = [[NSMutableArray alloc] initWithCapacity:0];
		linkedResizingMask = 0;
		linkedMinSize = NSMakeSize(0.0, 0.0);
		linkedMaxSize = NSMakeSize(0.0, 0.0);
	}
	return self;
}

- (void)dealloc
{
	[linkedViews dealloc];
	[super dealloc];
}


// SMViewLinking protocol methods

- (void)linkBorder:(SMViewLinkingBorderType)sourceBorder toView: 
	(NSView *)destView
			border:(SMViewLinkingBorderType)destBorder
{
	// does the dest view conforms to the SMViewLinking protocol?
	if ([[destView class] conformsToProtocol:@protocol(SMViewLinking)]  
		== NO) {return;}
	
	// determine the current distance
	NSRect sourceFrame = [[self superview] convertRect:[self frame]  
												toView:nil];
	// TODO: better (faster ?) transformation!!!
	NSRect destFrame = [[destView superview] convertRect:[destView  
		frame] toView:nil];
	// TODO: better (faster ?) transformation!!!
	CGFloat distance = SMViewLinkingBorderPosition(destFrame, destBorder)
		- SMViewLinkingBorderPosition(sourceFrame, sourceBorder);
	
	// add to the linkedViews array
	NSDictionary *linkedViewDict = [NSDictionary  
dictionaryWithObjectsAndKeys:
		destView, SMViewLinkingDestViewKeyName,
		[NSNumber numberWithInteger:sourceBorder],  
		SMViewLinkingSourceBorderKeyName,
		[NSNumber numberWithInteger:destBorder],  
		SMViewLinkingDestBorderKeyName,
		[NSNumber numberWithDouble:distance], SMViewLinkingDistanceKeyName,
		nil];
	[linkedViews addObject:linkedViewDict];
}

- (void)unlinkView:(NSView *)destView
{
	NSInteger i;
	NSDictionary * linkedViewDict;
	
	for (i = [linkedViews count] - 1; i--; i < 0) {
		linkedViewDict = [linkedViews objectAtIndex:i];
		if ([linkedViewDict objectForKey:SMViewLinkingDestViewKeyName] ==  
			destView) {
			[linkedViews removeObjectAtIndex:i];
		}
	}
}

- (void)moveLinkedBorder:(SMViewLinkingBorderType)border by:(CGFloat) 
	offset
{
	NSRect frame = [self frame];
	
	// move the border but consider resizing mask
	if (border == SMViewLinkingTopBorderType) {
		if (linkedResizingMask & SMViewLinkingResizesVertically) {
			frame.size.height += offset;
		} else {
			frame.origin.y += offset;
		}
	}
	if (border == SMViewLinkingBottomBorderType) {
		frame.origin.y += offset;
		if (linkedResizingMask & SMViewLinkingResizesVertically) {
			frame.size.height -= offset;
		}
	}
	if (border == SMViewLinkingLeftBorderType) {
		frame.origin.x += offset;
		if (linkedResizingMask & SMViewLinkingResizesHorizontally) {
			frame.size.width -= offset;
		}
	}
	if (border == SMViewLinkingRightBorderType) {
		if (linkedResizingMask & SMViewLinkingResizesHorizontally) {
			frame.size.width += offset;
		} else {
			frame.origin.x += offset;
		}
	}
	
	// check min/max size
	if ((linkedResizingMask & SMViewLinkingConstrainedToMinWidth)
		&& (frame.size.width < linkedMinSize.width))
	{
		frame.size.width = linkedMinSize.width;
	}
	if ((linkedResizingMask & SMViewLinkingConstrainedToMinHeight)
		&& (frame.size.height < linkedMinSize.height))
	{
		frame.size.height = linkedMinSize.height;
	}
	if ((linkedResizingMask & SMViewLinkingConstrainedToMaxWidth)
		&& (frame.size.width > linkedMaxSize.width))
	{
		frame.size.width = linkedMaxSize.width;
	}
	if ((linkedResizingMask & SMViewLinkingConstrainedToMaxHeight)
		&& (frame.size.height > linkedMaxSize.height))
	{
		frame.size.height = linkedMaxSize.height;
	}
	
	[self setFrame:frame];
	[[self superview] setNeedsDisplay:YES];
}

- (SMViewLinkingLinkedResizingMask)linkedResizingMask {
	return linkedResizingMask;
}

- (void)setLinkedResizingMask:(SMViewLinkingLinkedResizingMask)mask {
	linkedResizingMask = mask;
}

- (NSSize)linkedMinSize {
	return linkedMinSize;
}

- (void)setLinkedMinSize:(NSSize)minSize {
	linkedMinSize = minSize;
}

- (NSSize)linkedMaxSize {
	return linkedMaxSize;
}

- (void)setLinkedMaxSize:(NSSize)maxSize {
	linkedMaxSize = maxSize;
}


// overridden and private methods

- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];
	[self _updateLinkedViews];
}

- (void)_updateLinkedViews
{
	// loop thru all linked views and see if they have to change
	NSEnumerator *enumerator = [linkedViews objectEnumerator];
	NSDictionary *linkedViewDict;
	id destView;
	NSRect sourceFrame = [[self superview] convertRect:[self frame]  
												toView:nil];
	// TODO: better (faster ?) transformation!!!
	NSRect destFrame;
	SMViewLinkingBorderType sourceBorder, destBorder;
	CGFloat linkedDistance, actualDistance;
	
	while (linkedViewDict = [enumerator nextObject])
	{
		destView = [linkedViewDict objectForKey:SMViewLinkingDestViewKeyName];
		destFrame = [[destView superview] convertRect:[destView frame]  
											   toView:nil];
		// TODO: better (faster ?) transformation!!!
		sourceBorder = [[linkedViewDict  
objectForKey:SMViewLinkingSourceBorderKeyName] integerValue];
		destBorder = [[linkedViewDict  
objectForKey:SMViewLinkingDestBorderKeyName] integerValue];
		linkedDistance = [[linkedViewDict  
objectForKey:SMViewLinkingDistanceKeyName] doubleValue];
		
		actualDistance = SMViewLinkingBorderPosition(destFrame, destBorder)
			- SMViewLinkingBorderPosition(sourceFrame, sourceBorder);
		
		if (actualDistance != linkedDistance) {
			[destView moveLinkedBorder:destBorder by:(linkedDistance -  
													  actualDistance)];
		}
	}
}

@end