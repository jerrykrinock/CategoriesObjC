#import <Cocoa/Cocoa.h>


@interface NSMenuItem (WelcomeStart)

/*!
 @brief    Adds a suffix: "       Welcome! Start Here", in blue,
 to the end of an NSMenuItem

 @details  This is for cueing a new user what to do.
*/
- (void)addWelcomeStartHere ;

@end
