#import <Cocoa/Cocoa.h>

@interface NSSet (Identicalness)

/*!
 @brief    Returns YES if the receiver and a given set have
 exactly the same members, meaning the same pointer values

 @details  The documentation of -isEqualToSet: says that it
 does this, but in fact members must only be -isEqual in order
 for -isEqualToSet: to return YES.
*/
- (BOOL)isIdenticalToSet:(NSSet*)set ;

@end

