#import <Cocoa/Cocoa.h>

extern NSString* const constDiscontiguousTabViewHierarchyString ;

/*
 @brief    Methods for working with hierarchical tab views, which means tabs
 whose views or subviews of its tab view items also contain ("sub") tab views.
 */
@interface NSTabViewItem (SSYTabHierarchy)

/*
 @brief    Returns self, unless the receiver's view contains a (sub) tab view, 
 then returns the selected tab view item of the first such sub tab view, unless
 the view of that item contans a (subsub) tab view, then returns the selected
 tab view item of the first subsub tab view, etc. recursively until a leaf tab
 view item is found.
 
 @details  This method has some safety built into it.  If self, or any leaf item
 found during the recursion, does not respond as required (typically because the
 items is a NSTabViewItem but not a SSYHierarchicalTabViewItem), this method 
 stops and returns the deepest tab view item it has already found.  No
 exception is raised.
 
 The phrase "first … tab view" means the first in the array -[NSView subviews].
 You should probably have only one of these, unless you want to confuse users
 even more than having hierarchical tab view items already does :))
 
 @result   The tab view item returned is often the receiver itself.
 */
- (NSTabViewItem*)selectedLeafmostTabViewItem ;

/*
 brief    Searches the receiver's view and the descendant views (subviews,
 subsubviews, etc.) of this view until it finds an NSTabView, returning this
 item or nil if none was found
 
 @details  The search is depth-first.  This works as expected if there is only
 one such tab view in the descendant views.
 */
- (NSTabView*)deeperTabView ;

@end
