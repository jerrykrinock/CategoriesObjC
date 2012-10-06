#import <Cocoa/Cocoa.h>
#import "NSError+SSYAdds.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > 1060
#define SSYHelpAnchorErrorKey NSHelpAnchorErrorKey
#endif

// Macros for making NSErrors

/*
 Quick macros to make a simple error without much thinking
 First argument is NSInteger, second is NSString*.
 Adds the current method name from __PRETTY_FUNCTION__ as an
 object in the userInfo dictionary.
 */
#define SSYMakeError(code__,localizedDescription__) [NSError errorWithLocalizedDescription:localizedDescription__ code:code__ prettyFunction:__PRETTY_FUNCTION__]
#define SSYMakeHTTPError(code__) [NSError errorWithHTTPStatusCode:code__ prettyFunction:__PRETTY_FUNCTION__]
#define SSYAddMethodNameInError(error__) if (error__){error__=[error__ errorByAddingUserInfoObject:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] forKey:SSYMethodNameErrorKey];}
#define SSYOverwriteMethodNameInError(error__) if (error__){error__=[error__ errorByOverwritingUserInfoObject:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] forKey:SSYMethodNameErrorKey];}

// Macros for initializing and assigning an NSError** named error_p

/*
 These are useful within functions that get an argument (NSError**)error_p
 Use SSYInitErrorP to assign it to *error_p to nil at beginning of function.
 (This is optional.  Apple doesn't do it in their methods that take NSError**,
 but I don't like the idea of leaving it unassigned.)
 Then, use the next two to assign to *error_p if/when an error occurs.
 Benefit: All of these macros check that error_p != NULL before assigning.
*/
#define SSYAssignErrorP(_error) if (error_p != NULL) {*error_p = _error ;}
#define SSYInitErrorP SSYAssignErrorP(nil) ;
#define SSYMakeAssignErrorP(_code,_localizedDetails) SSYAssignErrorP(SSYMakeError(_code,_localizedDetails))
#define SSYAddMethodNameToErrorP 	if (error_p && (*error_p != nil)) {*error_p = [*error_p errorByAddingPrettyFunction:__PRETTY_FUNCTION__] ;}


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
 @brief    Key to the URL of a document which, when opened, will produce
 an NSDocument which conforms to the NSErrorRecoveryAttempting Protocol.
 
 @details  This is useful when passing NSError objects between processes.
 When presenting the error, you get it back by presenting -openRecoveryAttempterAndDisplay.
  */
extern NSString* const SSYRecoveryAttempterUrlErrorKey ;

/*!
 @brief    Key which you may use in error userInfo dictionaries as desired

 @details  A suggested use is, for example, if you are making requests
 from a server, and the server throttles you and gives you a suggested
 time to retry your request.
*/
extern NSString* const SSYRetryDateErrorKey ;

/*!
 @brief    Key to an NSNumber which indicates that the app presenting the
 receiver has an -[NSApp delegate] which conforms to the
 NSErrorRecoveryAttempting Protocol and should be able to recover for
 the receiver.
 
 @details  This is useful when passing NSError objects between processes.
 */
extern NSString* const SSYRecoveryAttempterIsAppDelegateErrorKey ;

/*!
 @brief    Key to an HTTP Status Code returned by a server.
 */
extern NSString* const SSYHttpStatusCodeErrorKey ;

/*!
 @brief    Text which will appear at the end of a -longDescription or
 -mailableLongDescription if it was truncated to meet length limitations.
*/
extern NSString* const SSYDidTruncateErrorDescriptionTrailer ;

@interface NSError (SSYAdds) 

/*!
 @brief    Returns an error domain for the current process, which is used
 by the other error-generating methods in this category.

 @details  For applications, this will be the main bundle identifier.&nbsp;
 For processes that don't have an [NSBundle mainBundle], this will be the
 executable name, specifically the last path component of the process'
 first command-line argument.
*/
+ (NSString*)myDomain ;

+ (NSError*)errorWithLocalizedDescription:(NSString*)localizedDescription
									 code:(NSInteger)code
						   prettyFunction:(const char*)prettyFunction ;

#pragma mark * Methods for adding userInfo keys to errors already created

/*!
 @brief    Adds or changes a string value for string key NSLocalizedDescriptionKey to userInfo 
 of a copy of the receiver and returns the copy, unless the parameter is nil, then
 returns the receiver.
 @details  This may be used to change an error's localized description.
 @param    newText  The string value to be added for key NSLocalizedDescriptionKey
 */
- (NSError*)errorByAddingLocalizedDescription:(NSString*)newText ;

/*!
 @brief    Adds or overwrites a string value for string key NSLocalizedFailureReasonErrorKey
 to userInfo a copy of the receiver and returns the copy, unless the parameter is nil, then
 returns the receiver.
 @details  If you want to append a reason instead of overwriting, use
 -errorByAppendingLocalizedFailureReason: instead.
 @param    newText  The string value to be added for key NSLocalizedFailureReasonErrorKey
 */
- (NSError*)errorByAddingLocalizedFailureReason:(NSString*)newText ;

/*!
 @brief    Adds or appends a string value for string key NSLocalizedFailureReasonErrorKey
 to userInfo a copy of the receiver and returns the copy, unless the parameter is nil, then
 returns the receiver.
 @details  If you want to overwrite any existing failure reason instead of appending, use
 -errorByAddingLocalizedFailureReason: instead.
 @param    newText  The string value to be added for key NSLocalizedFailureReasonErrorKey
 */
- (NSError*)errorByAppendingLocalizedFailureReason:(NSString*)newText ;

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
 @brief    Adds a string value for string key NSLocalizedRecoverySuggestionErrorKey to userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @param    newText  The string value to be added for key NSLocalizedRecoverySuggestionErrorKey
 */
- (NSError*)errorByAddingLocalizedRecoverySuggestion:(NSString*)newText ;

/*!
 @brief    Adds a string value for string key NSRecoveryAttempterErrorKey to userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @details  If the parameter is nil, this method is a no-op.
 @param    recoveryAttempter  An object which conforms to the NSErrorRecoveryAttempting
 informal protocol
 */
- (NSError*)errorByAddingRecoveryAttempter:(id)recoveryAttempter ;

/*!
 @brief    Adds a string value for string key SSYRecoveryAttempterUrlErrorKey to userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @details  If the parameter is nil, this method is a no-op.
 @param    recoveryAttempter  See SSYRecoveryAttempterUrlErrorKey documentation.
 */
- (NSError*)errorByAddingRecoveryAttempterUrl:(NSURL*)url ;

/*!
 @brief    Adds an NSNumber with -boolValue = YES for string key SSYRecoveryAttempterIsAppDelegateErrorKey
 to userInfo of a copy of the receiver and returns the copy.
 */
- (NSError*)errorByAddingRecoveryAttempterIsAppDelegate ;

/*!
 @brief    Adds an array value for string key NSLocalizedRecoveryOptionsErrorKey to userInfo of a copy of
 the receiver and returns the copy, unless the parameter is nil, then returns the receiver.
 @details  If the parameter is nil, this method is a no-op.
 @param    options  The array of strings which will be added for key NSLocalizedRecoverySuggestionErrorKey
 */
- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions ;
	
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
 @brief    Adds an string which can be retrieved by -helpAnchor to the receiver's userInfo
 and returns an autoreleased copy of the receiver, unless the parameter is nil, then returns the receiver.
 @details  This can be used to encapsulate in the error a string which your presentError:
 or alertError: method can use to target a Help button.
 */
- (NSError*)errorByAddingHelpAnchor:(NSString*)helpAnchor ;

#if MAC_OS_X_VERSION_MIN_REQUIRED < 1060
/*!
 @brief    Returns the string which was added to the receiver's userInfo by
 -errorByAddingHelpAnchor:, or nil if no such invocation has been added.
 */
- (NSString*)helpAnchor ;
#else
// Apple implemented this method starting with the 10.6 SDK
#endif

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

/*!
 @brief    Returns a readable multiline description which contains
 the -descriptionForDialog of the receiver and all of its
 antecedent underlying errors.
 */
- (NSString*)localizedDeepDescription ;

- (NSError*)errorByAddingTimestamp:(NSDate*)date ;

- (NSError*)errorByAddingTimestampNow ;

- (NSDate*)timestamp ;

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
 @brief    If the receiver's -userInfo contains a value for key @"Path",
 and if this path begins with @"/Volumes/SomeVolume/", and if SomeVolume
 is apparently not mounted, returns a replica of the receiver with a
 localized recovery suggestion to mount SomeVolume added; otherwise,
 returns the receiver.
*/
- (NSError*)maybeAddMountVolumeRecoverySuggestion ;

/*!
 @brief    Adds a "Backtrace" key to the userInfo of a copy of 
 the receiver and returns the copy.  The value of the key is
 the current stack backtrace, provided by SSYDebugBacktrace().
 */
- (NSError*)errorByAddingBacktrace ;

/*!
 @brief    Returns YES if the receiver has the special key/value pair added by
 -errorByAddingIsOnlyInformational.&nbsp;  Otherwise, returns NO.
 */
- (BOOL)isOnlyInformational ;


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
 @brief    An improved -description, which gives a detailed, multi-line
 description of the error, including all keys and values in the userInfo
 dictionary.

 @details  Individual keys and values in the userInfo dictionary, as well
 as the entire description of the userInfo, are truncated in the middle
 to reasonable lengths if they are unreasonably long.
 
 If this category were instead a class, I would instead override
 -description with the implementation of this method.

 This method will call itself
 in the event that one of the values in the userInfo dictionary is itself
 an NSError, and this should occur when one of the keys is
 NSUnderlyingErrorKey.&nbsp; The lines in the output string will each
 be indented by several spaces.
 
 To prevent runaway, the keys in the userInfo, values in userInfo, and
 length of the entire output are truncated to non-ridiculous lengths.
 
 If the result is truncated, it will end in SSYDidTruncateErrorDescriptionTrailer.
*/
- (NSString*)longDescription ;

/*!
 @brief    Same as -longDescription, except the truncation limits are
 lower, appropriate to fit in the body of an email message.
*/
- (NSString*)mailableLongDescription ;

/*!
 @brief    Returns a localized description appropriate for displaying the essence
 of the receiver to the user in a dialog.

 @details  Begins with the receiver's localizedDescription,
 Then if there is a localizedFailureReason, appends two line feeds, and a localized
 label followed by the value of localizedFailureReason.
 Then if there is a localizedRecoverySuggestion, appends two line feeds, and a localized
 label followed by the value of localizedRecoverySuggestion.
 Then if the class object NSError responds to selector additionalKeysInDescriptionForDialog
 (which must return an array of strings), will iterate through each of these
 strings and, for each which has a value in the receiver's userInfo dictionary,
 appends two line feeds, and a localized label for the key followed by its value
 from userInfo.  
*/
- (NSString*)descriptionForDialog ;

/*!
 @brief    Returns a keyed archive of the receiver, after replacing any unserializable
 objects in its -userInfo by their -description. 

 @details  NSError conforms to NSCoding, but if you try and archive one whose
 userInfo dictionary contains an object which does not, you'll get an exception.&nbsp; 
 This method iterates recursively through the userInfo dictionary, replacing any object
 which is not serializable by its -description, then as a convenience, applies
 -[NSKeyedArchiver archivedDataWithRootObject] and returns the result.&nbsp; 
 To-do: Could relax the 'serializable' requirement to 'encodeable'.&nbsp; 
 See NSObject+DeepCopy.
*/
- (NSData*)keyedArchive ;

/*!
 @brief    Returns the error code of the error which is at
 the bottom of the receiver's stack of underlying errors.

 @details  If the receiver has nil underlyingError, returns
 the error code of the receiver.
*/
- (NSInteger)mostUnderlyingErrorCode ;

/*!
 @brief    Returns a set of numbers whose intValues are the -code of the receiver and
 the codes of all underlying errors, but only if the relevant error's domain is
 equal to a given domain, unless domain is nil in which case it's the codes of
 all underlying errors.
*/
- (NSSet*)allInvolvedCodesInDomain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in a given domain
 and has a code in a given set, unless the given domain is nil then it returns whether or
 not the receiver or any of its underlying errors simply has a code in a given set.
 */
- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes
						 domain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors has a code 
 in a given set.
 */
- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in +myDomain
 and has a code in a given set.
 */
- (BOOL)involvesOneOfMyCodesInSet:(NSSet*)targetCodes ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in a given domain
 and has a given code, unless the given domain is nil then it returns whether or
 not the receiver or any of its underlying errors simply has the given code.
 */
- (BOOL)involvesCode:(NSInteger)code
			  domain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors has a given code.
 */
- (BOOL)involvesCode:(NSInteger)code ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in +myDomain
 and has a given code.
 */
- (BOOL)involvesMyDomainAndCode:(NSInteger)code ;

/*!
 @brief    Returns NO if the receiver's domain is NSCocoaErrorDomain and code
 is NSFileReadNoSuchFileError, YES otherwise
 
 @details  NSFileReadNoSuchFileError in NSCocoaErrorDomain is returned by
 -[NSFileManager contentsOfDirectoryAtPath:error:] if the given path does
 not exist.  Use this method to process only other errors, like this
 • if ([error isNotFileNotFoundError]) {
 •     // This is a serious error, do something about it
 •     …
 • }
 
 */
- (BOOL)isNotFileNotFoundError ;

- (BOOL)isUserCancelledCocoaError ;

/*!
 @brief    Returns whether or not the receiver has either a recovery 
 attempter or a recovery URL, and has at least one recovery option.
 
 @details  A replacement for -localizedRecoveryOptions which also checks the
 availability of a recovery attempter and that -localizedRecoveryOptions
 is not empty.  This method differs from -localizedRecoveryOptions in that it
 will return nil if the receiver's info dictionary does not include either
 a recoveryAttempter or recoveryAttempterUrl or recoveryAttempterIsAppDelegate
 != YES, or if the count of -localizedRecoveryOptions is 0.
 Generally, if this method returns nil, when displaying the error, you should
 display only the usual "OK" button instead of recovery options.
 
 When checking for the attempters, this method only checks to see if either
 of the three values are non-nil/YES.  It does not test whether or not the
 recoveryAttempter or app delegate conforms to NSErrorRecoveryAttempting
 Protocol, nor test if there is even a file at the path specified by the
 recoveryAttempterUrl.
 The idea is that, when displaying the error, you assume that it is
 well-formed, and not worry about actual performance until after and *if*
 the user clicks a recovery option.
 */
- (BOOL)isRecoverable ;

/*!
 @brief    Returns the deepest of either the receiver, or one of the underlying
 errors in its underlyingError lineage, which is recoverable, or nil if none
 of these errors are recoverable.

 @details  The idea behind this is that the deepest underlying error is the
 root cause from which you cant to recover.  You should use this method in
 *both* your error presentation method(s) *and* in your
 attemptRecoveryFromError::::: and attemptRecoveryFromError:: method(s).
 (If you only use it in presentation or only in attempting recovery, you 
 might miss recovery options, get the wrong recovery option performed, etc.)
 
 Recoverability is determined by -isRecoverable.  If none of the
 constituent errors are recoverable, returns nil.
*/
- (NSError*)deepestRecoverableError ;
	
/*!
 @brief    A replacement for -recoveryAttempter which also uses the receiver's
 recovery attempter URL, if any.

 @details  First, this method returns the receiver's -recoveryAttempter, if any.
 Second, if that is nil, and if the receiver has a -recoveryAttempterUrl, it returns
 nil if the given recoveryOption is not NSAlertAlternateReturn (*), and otherwise asks
 the shared document controller to open the document specified by the
 recoveryAttempterUrl and returns whatever results (which may be nil).  
 Third, if the receiver's -recoveryAttempterUrl is nil, and if the receiver's
 -userInfo has a value for SSYRecoveryAttempterIsAppDelegateErrorKey whose
 -boolValue is YES, it returns -[NSApp delegate].
 
 (*) The recoveryOption value of NSAlertAlternateReturn is assumed to mean "Cancel".
 Now, I don't like the idea of peeking into the recoveryOption in this
 method.  It kind of breaks encapsulation.  But otherwise we'd open
 a document just to have it tell us that the recovery was cancelled,
 which would look stupid and be stupid.
 @param    error_p  Pointer which will, upon return, if the receiver does not
 have a recovery attempter, does have a recovery attempter URL, and if an
 attempt was made to open the document specified by that recovery attempter
 URL, and the attempt failed, and if error_p is not NULL, point to
 an NSError (yes, a*nother* NSError) describing the problem with opening
 the document.  Note that 'nil' is a legitimate return value for this 
 method, andthe fact that this method returns nil does
 not necessarily mean that error_p will point to an error.
 @result   The receiver's recovery attempter, or the NSDocument produced by
 opening the receiver's recoveryAttempterUrl, or nil if neither is available.
*/
- (id)openRecoveryAttempterForRecoveryOption:(NSInteger)recoveryOption 
									 error_p:(NSError**)error_p ;

@end
