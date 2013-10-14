#import <Cocoa/Cocoa.h>
#import "NSError+InfoAccess.h"

/*!
 @brief    Key to a string used in the userInfo dictionary of an NSError
 which gives the name of the method in which the error occurred.
 */
extern NSString* const SSYMethodNameErrorKey ;

/*!
 @brief    Key to a localized string used in the userInfo dictionary of an NSError
 suitable for use as a "title" when displaying the error to a user.
*/
extern NSString* const SSYLocalizedTitleErrorKey ;

/*!
 @brief    Key to an NSException in the userInfo dictionary of an NSError
 which was the cause of the error.
*/
extern NSString* const SSYUnderlyingExceptionErrorKey ;

/*!
 @brief    Key to an NSDate which may be used to timestamp when the error occurred.
 */
extern NSString* const SSYTimestampErrorKey ;

/*!
 @brief    Key to an HTTP Status Code returned by a server.
 */
extern NSString* const SSYHttpStatusCodeErrorKey ;

@interface NSError (InfoAccess) 

/*!
 @brief    Adds object for key into the userInfo of a copy of the receiver and
 returns the copy, unless the parameter is nil, then returns the receiver.
 
 @details  If proposedKey already has a value in the receiver's userInfo,
 then the description (in case it is not a string) of the proposedKey is
 extracted and a sequence number is appended to make a unique key, and the
 existing value is set under this new key.  If a value already exists for
 that key, then it too is changed to have a key constructed with a higher
 sequence number.
 
 Example:
 
 Before this method is invoked, userInfo has:
 *   key="Foo"    object="Fred"
 *   key="Foo-01  object="Barney"
 
 Now say we invoke this method with key="Foo" and object="Wilma".
 The result in userInfo will be:
 *   key="Foo"    object="Wilma"
 *   key="Foo-01  object="Fred"
 *   key="Foo-02  object="Barney"
 
 If the 'object' parameter is nil, this method is a no-op.
 
 @param    object  of the pair to be added
 @param    key  of the pair to be added
 */
- (NSError*)errorByAddingUserInfoObject:(id)object
								 forKey:(NSString*)proposedKey ;

/*!
 @brief    Same as errorByAddingUserInfoObject:forKey: except overwrites
 any existing key instead of modifying proposedKey to be unique
 */
- (NSError*)errorByOverwritingUserInfoObject:(id)object
									  forKey:(NSString*)key ;

- (NSError*)errorByAddingLocalizedFailureReason:(NSString*)newText ;

- (NSError*)errorByAddingLocalizedDescription:(NSString*)newText ;

/*!
 @brief    Adds a string value for string key NSLocalizedRecoverySuggestionErrorKey to userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @param    newText  The string value to be added for key NSLocalizedRecoverySuggestionErrorKey
 */
- (NSError*)errorByAddingLocalizedRecoverySuggestion:(NSString*)newText ;

/*!
 @brief    Adds a string value for string key NSRecoveryAttempterErrorKey to
 userInfo of a copy of the receiver and returns the copy, unless the parameter
 is nil, then returns the receiver.
 @details  If the parameter is nil, this method is a no-op.
 @param    recoveryAttempter  An object which conforms to the
 NSErrorRecoveryAttempting informal protocol
 */
- (NSError*)errorByAddingRecoveryAttempter:(id)recoveryAttempter ;

/*!
 @brief    Adds a string value for string key SSYMethodNameErrorKey to userInfo 
 a copy of the receiver and returns the copy, unless the parameter is NULL, then
 returns the receiver.
 
 @details  Invokes -errorByAddingUserInfoObject:forKey:, so that if such a string
 key already exists, it is not overwritten.  See errorByAddingUserInfoObject:forKey:.
 
 @param    newText  The C string to be added for key SSYprettyFunctionErrorKey
 */
- (NSError*)errorByAddingPrettyFunction:(const char*)prettyFunction ;

/*!
 @brief    Adds an array value for string key NSLocalizedRecoveryOptionsErrorKey
 to userInfo of a copy of the receiver and returns the copy, unless the
 parameter is nil, then returns the receiver.
 @details  If the parameter is nil, this method is a no-op.
 @param    options  The array of strings which will be added for key
 NSLocalizedRecoverySuggestionErrorKey
 */
- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions ;
	
/*!
 @brief    Adds an string which can be retrieved by -helpAnchor to the receiver's userInfo
 and returns an autoreleased copy of the receiver, unless the parameter is nil, then returns the receiver.
 @details  This can be used to encapsulate in the error a string which your presentError:
 or alertError: method can use to target a Help button.
 */
- (NSError*)errorByAddingHelpAnchor:(NSString*)helpAnchor ;

/*!
 @brief    Appends a new string to a given key in a copy of the receiver,
 and usually returns the copy, autoreleased
 
 @details  If the receiver already has text for the given key, two
 ASCII space characters are appended before appending the moreText.
 Otherwise, the moreText becomes the localized description in the result.
 If the moreText parameter is nil, this method simply returns the
 receiver (self) instead of an autoreleased copy.
 */
- (NSError*)errorByAppendingText:(NSString*)moreText
                   toValueForKey:(NSString*)key ;

/*!
 @brief    Invokes -errorByAppendingText:toValueForKey:, passing the receiver's
 NSLocalizedDescriptionErrorKey as the key, effectively appending to the
 receiver's localized description, and returns the result
 */
- (NSError*)errorByAppendingLocalizedDescription:(NSString*)moreText ;

/*!
 @brief    Invokes -errorByAppendingText:toValueForKey:, passing the receiver's
 NSLocalizedFailureReasonErrorKey as the key, effectively appending to the
 receiver's localized failure reason, and returns the result
 */
- (NSError*)errorByAppendingLocalizedFailureReason:(NSString*)moreText ;

/*!
 @brief    Returns the object for key NSUnderlyingErrorKey in the receiver's userInfo dictionary
*/
- (NSError*)underlyingError ;

/*!
 @brief    Sends -underlyingError to the receiver, then sends -underlyingError
 recursively to the returned underlyingError, and finally returns the last
 non-nil underlying error.
*/
- (NSError*)bottomError ;

/*!
 @brief    Adds an error for string key NSUnderlyingErrorKey to userInfo of a copy of 
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @details  Note that to make an "overlying" error, send this message to a new error
 and pass the previous, underlying error.
 @param    underlyingError  The error value to be added for key NSUnderlyingErrorKey
 */
- (NSError*)errorByAddingUnderlyingError:(NSError*)underlyingError ;

/*!
 @brief    Adds keys and values explaining a given exception to the userInfo
 of a copy of the receiver and returns the copy, unless the parameter is nil, then returns the receiver.

 @param    exception  The exception whose info is to be added
*/
- (NSError*)errorByAddingUnderlyingException:(NSException*)exception ;

/*!
 @brief    Adds a value for string key SSYLocalizedTitleErrorKey to userInfo of a copy of 
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @param    title  The string value to be added for key SSYLocalizedTitleErrorKey
 */
- (NSError*)errorByAddingLocalizedTitle:(NSString*)title ;

/*!
 @brief    Invokes -errorByAppendingText:toValueForKey:, passing the receiver's
 NSLocalizedRecoverySuggestionErrorKey as the key, effectively appending to the
 receiver's localized recovery suggestion, and returns the result
 */
- (NSError*)errorByAppendingLocalizedRecoverySuggestion:(NSString*)moreText ;

/*!
 @brief    Returns a replica of the receiver, except that if 
 the receiver's userInfo contains NSRecoveryAttempterErrorKey,
 the returned replica will not.
 
 @details  This is useful prior to archiving an error which will be later
 presented in a context where its indicated recovery is not possible.
 Note that it does not remove the SSYRecoveryAttempterUrlErrorKey, or the
 NSRecoveryOptionsErrorKey, or the SSYRecoveryAttempterIsAppDelegateErrorKey,
 because they should work, and will be tried if NSRecoveryAttempterErrorKey
 is removed.
*/
- (NSError*)errorByRemovingRecoveryAttempter ;

/*!
 @brief    Returns the string value in the receiver's userInfo dictionary
 for the key SSYLocalizedTitleErrorKey, or if that is nil, the first
 line of text from the receiver's localizedDescripiton, or if that is nil,
 nil.
*/
- (NSString*)localizedTitle ;

- (NSError*)errorByAddingTimestamp:(NSDate*)date ;

- (NSError*)errorByAddingTimestampNow ;

- (NSDate*)timestamp ;


@end
