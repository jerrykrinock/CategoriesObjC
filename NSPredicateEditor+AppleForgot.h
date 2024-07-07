#import <Cocoa/Cocoa.h>

@interface NSPredicateEditor (AppleForgot)

/*!
 @brief    Removes all rows, including the root row, and adds a specified
 number of new "clean" rows
 
 @details  This method must be called before setting the object value, which is
 the predicate, of a NSPredicateEditor.  It seems to be an oversight that
 Apple did not build this into the implementation of
 -[NSPredicatEditor setObjectValue:], but even in year 2023 macOS 14 it is
 still necessary.
 
 For our purposes, probably leaving dirty rows would be OK because
 setting the object value (predicate) will wipe out the old row contents, but
 it seems like better hygiene to remove them.
 */
- (void)changeRowCountTo:(NSInteger)count ;

@end
