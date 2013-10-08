#import "SSYShoeboxDocument-Categories.h"


@implementation NSMenuItem (SSYShoeboxDocument)

- (BOOL)looksLikeOpenRecent {
    BOOL answer = NO ;
    
    for (NSMenuItem* submenuItem in [[self submenu] itemArray]) {
        if ([submenuItem action] == @selector(clearRecentDocuments:)) {
            // NSLog(@"   subAction = %@", NSStringFromSelector([submenuItem action])) ;
            answer = YES ;
            break ;
        }
    }
    
    return answer ;
}


@end

@implementation NSMenu (SSYShoeboxDocument)

- (void)removeNonShoeboxMultiDocItems {
    NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init] ;
    NSInteger i = 0 ;
    NSInteger countOfItemsSinceLastSeparator = 0 ;
    for (NSMenuItem* item in [self itemArray]) {
        SEL action = [item action] ;
        if (
            //                                                     Affected Menu Item
            //                                                     ------------------
            (action == @selector(openDocument:))                // "Open"
            || [item looksLikeOpenRecent]                       // "Open Recent >"
            // || (action == @selector(performClose:))          // "Close" (Note 1)
            || [NSStringFromSelector(action) isEqualToString:@"closeAll:"]  // "Close All" (Note 1)
            || (action == @selector(duplicateDocument:))        // "Duplicate"
            || (action == @selector(renameDocument:))           // "Rename…"
            // || (action == @selector(moveDocument:))          // "Move To…" (Note 2)
            || (action == @selector(saveDocumentAs:))        // "Save As…" (Note 3)
            || (action == @selector(revertDocumentToSaved:)) // "Revert" (Note 3)
            /*
             * Note 1.  The Apple shoebox app iPhoto has a File > Close menu,
             *    which *quits* the app, which I think is silly.  And if you
             *    remove that menu item, an even more silly item, "Close All",
             *    appears.  But users expect our apps to be silly like Apple's,
             *    so I have commented out the first one.  For the latter, we
             *    use NSStringFromSelector because apparently closeAll: is not
             *    declared in the SDK.
             * Note 2.  You could uncomment this line if you want this menu item
             *    removed.
             * Note 3.  This item may or may not be removed by Cocoa, depending
             *    on the Mac OS X version and on what other items are present.
             *    We leave it in for robustness.
             */
            ) {
            [indexesToRemove addIndex:i] ;
        }
        else if ([item isSeparatorItem]) {
            if (countOfItemsSinceLastSeparator == 0) {
                [indexesToRemove addIndex:i] ;
            }
            else {
                countOfItemsSinceLastSeparator = 0 ;
            }
        }
        else {
            countOfItemsSinceLastSeparator++ ;
        }
        i++ ;
    }
    
    i = [indexesToRemove lastIndex] ;
    while ((i != NSNotFound)) {
        [self removeItemAtIndex:i] ;
        i = [indexesToRemove indexLessThanIndex:i] ;
    }
    
    [indexesToRemove release] ;
}

@end


@implementation BkmxDoc (SSYShoeboxDocument)

- (void)menuNeedsUpdate:(NSMenu*)menu {
    [super menuNeedsUpdate:menu] ;
    
    NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init] ;
    NSInteger i = 0 ;
    NSInteger countOfItemsSinceLastSeparator = 0 ;
    for (NSMenuItem* item in [menu itemArray]) {
        SEL action = [item action] ;
        if (
            (action == @selector(renameDocument:)) ||
            (action == @selector(moveDocument:)) ||
            (action == @selector(duplicateDocument:)) ||
            (action == @selector(lockDocument:))
            ) {
            [indexesToRemove addIndex:i] ;
        }
        else if ([item isSeparatorItem]) {
            if (countOfItemsSinceLastSeparator == 0) {
                [indexesToRemove addIndex:i] ;
            }
            else {
                countOfItemsSinceLastSeparator = 0 ;
            }
        }
        else {
            countOfItemsSinceLastSeparator++ ;
        }
        i++ ;
    }
    
    i = [indexesToRemove lastIndex] ;
    while ((i != NSNotFound)) {
        [menu removeItemAtIndex:i] ;
        i = [indexesToRemove indexLessThanIndex:i] ;
    }
    
#if NO_ARC
    [indexesToRemove release] ;
#endif
}

@end
