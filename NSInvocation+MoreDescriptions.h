#import <Cocoa/Cocoa.h>


@interface NSInvocation (MoreDescriptions)

/*!
 @brief    Like -description except appends the receiver's target,
 selector name and arguments.&nbsp;  Handy for debugging.
 
 @details  The -shortDescription of the target and arguments
 are given.  Otherwise, you'd have a "long long" description,
 which would usually be too long.
 */
- (NSString*)longDescription ;

@end
