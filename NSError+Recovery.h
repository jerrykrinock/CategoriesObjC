#import <Foundation/Foundation.h>

@interface NSError (Recovery)

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
