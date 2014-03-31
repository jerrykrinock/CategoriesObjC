#import <Foundation/Foundation.h>
#import "NSError+SSYInfo.h"

@interface NSError (SSYInfo)

/*!
 @brief    Adds an invocation which can be retrieved by -didRecoverInvocation to the receiver's userInfo
 and returns an autoreleased copy of the receiver, unless the parameter is nil, then returns the receiver.
 @details  This can be used to encapsulate in the error an invocation which you can invoke after
 a successful recovery occurs.
 */
- (NSError*)errorByAddingDidRecoverInvocation:(NSInvocation*)didRecoverInvocation ;

/*!
 @brief    Returns the invocation which was added to the receiver's userInfo by
 -errorByAddingDidRecoverInvocation:, or nil if no such invocation has been added.
 */
- (NSInvocation*)didRecoverInvocation ;

/*!
 @brief    Adds a special key/value pair to the userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the
 receiver.&nbsp;  The special key/value pair causes
 the returned error to return NO when sent -shouldShowSupportEmailButton.
 */
- (NSError*)errorByAddingDontShowSupportEmailButton ;

/*!
 @brief    Returns NO if the receiver has the special key/value pair added by
 -errorByAddingDontShowSupportEmailButton.&nbsp;  Otherwise, returns YES.
 */
- (BOOL)shouldShowSupportEmailButton ;

/*!
 @brief    Adds a special key/value pair to the userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns
 the receiver.&nbsp;  The special key/value pair causes
 the returned error to return YES when sent -isOnlyInformational.
 */
- (NSError*)errorByAddingIsOnlyInformational ;

/*!
 @brief    Returns YES if the receiver has the special key/value pair added by
 -errorByAddingIsOnlyInformational.&nbsp;  Otherwise, returns NO.
 */
- (BOOL)isOnlyInformational ;

/*!
 @brief    Adds a "Backtrace" key to the userInfo of a copy of
 the receiver and returns the copy.  The value of the key is
 the current stack backtrace, provided by SSYDebugBacktrace().
 */
- (NSError*)errorByAddingBacktrace ;

/*!
 @brief    Adds a special key/value pair to the userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns
 the receiver.&nbsp;  The special key/value pair causes
 the returned error to return YES when sent -isLogged.
 */
- (NSError*)errorByAddingIsLogged ;

/*!
 @brief    Returns YES if the receiver has the special key/value pair added by
 -errorByAddingIsLogged  Otherwise, returns NO.
 */
- (BOOL)isLogged ;

/*!
 @brief    Returns an error which is identical to the receiver except the
 error's code is changed to a different integer
 */
- (NSError*)errorByChangingCodeTo:(NSInteger)code ;

@end
