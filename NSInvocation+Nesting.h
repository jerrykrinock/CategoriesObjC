#import <Cocoa/Cocoa.h>


@interface NSInvocation (Nesting) 

/*!
 @brief    Returns an invocation which, when invoked, will invoke,
 in order and one at a time, the invocations in a given array
 of invocations.
*/
+ (NSInvocation*)invocationWithInvocations:(NSArray*)invocations ;

/*!
 @brief    Returns whether or not the receiver is a product of
 +invocationWithInvocations or equivalent.
*/
- (BOOL)hasEggs ;

@end
