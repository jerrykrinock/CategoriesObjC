#import "NSTabViewItem+SSYTabHierarchy.h"

NSString* const constDiscontiguousTabViewHierarchyString = @"Discontiguous tab view hierarchy" ;

@interface NSView (SSYTabSubviews)

- (NSTabViewItem*)deeplySelectedTabViewItem ;
- (NSTabView*)deeperTabView ;

@end

@implementation NSView (SSYTabSubviews)

- (NSTabViewItem*)deeplySelectedTabViewItem {
    NSTabViewItem* selectedChild = nil ;
    if ([self respondsToSelector:@selector(selectedTabViewItem)]) {
        // self is a tab view
        selectedChild = [(NSTabView*)self selectedTabViewItem] ;
    }
    else {
       for (NSView* subview in [self subviews]) {
            selectedChild = [subview deeplySelectedTabViewItem] ;
            if (selectedChild) {
                break ;
            }
        }
    }
    
    return selectedChild ;
}

- (NSTabView*)deeperTabView {
    NSTabView* deeperTabView = nil ;
    for (NSView* subview in [self subviews]) {
        if ([subview isKindOfClass:[NSTabView class]]) {
            deeperTabView = (NSTabView*)subview ;
        }
        else {
            deeperTabView = [subview deeperTabView] ;
        }
        
        if (deeperTabView) {
            break ;
        }
    }
    
    return deeperTabView ;
}


@end

@implementation NSTabViewItem (SSYTabHierarchy)

- (NSTabViewItem*)selectedChild {
    NSTabViewItem* selectedChild = [[self view] deeplySelectedTabViewItem] ;

    return selectedChild ;
}

- (NSTabViewItem*)selectedLeafmostTabViewItem {
    NSTabViewItem* leafItem = self ;
    NSTabViewItem* selectedChild = nil ;
   do {
        // This is in case the leaf item in a tree of SSYHierarchicalTabViewItem
        // objects is not itself a class descendant of
        // SSYHierarchicalTabViewItem.  It is also for safety,
        // in case someone sends this message to a tab view item
        // which is not or does not inherit from this class.
        if (![leafItem respondsToSelector:@selector(selectedChild)]) {
          break ;
        }
        
        selectedChild = [leafItem selectedChild] ;
       if ([selectedChild isKindOfClass:[NSTabViewItem class]]) {
            leafItem = selectedChild ;
        }
    } while (selectedChild != nil) ;
	
    return leafItem ;
}

- (NSTabView*)deeperTabView {
    return [[self view] deeperTabView] ;
}



@end
