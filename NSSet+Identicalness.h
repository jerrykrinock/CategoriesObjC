#import <Cocoa/Cocoa.h>

@interface NSSet (Identicalness)

/*!
 @brief    Returns YES if the receiver and a given set have
 exactly the same members, meaning the same pointer values

 @details  Apple's documentation of -isEqualToSet: states that objects are
 compared using -isEqual:.  This method is for when you need a more strict
 comparison.
*/
- (BOOL)isIdenticalToSet:(NSSet*)set ;

@end

