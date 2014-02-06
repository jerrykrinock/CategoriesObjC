#import <Foundation/Foundation.h>

/*!
 @brief    Text which will appear at the end of a -longDescription or
 -mailableLongDescription if it was truncated to meet length limitations.
 */
extern NSString* const SSYDidTruncateErrorDescriptionTrailer ;


@interface NSError (MoreDescriptions)


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
 @brief    Returns a readable multiline description which contains
 the -descriptionForDialog of the receiver and all of its
 antecedent underlying errors.
 */
- (NSString*)localizedDeepDescription ;

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
 Then, if there is a SSYTimestampErrorKey, and if that timestamp is older than
 10 seconds, appends to line feeds, and then two lines giving the timestamp.
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
 @brief    Returns a string giving only the code and the domain of the receiver
 and all of its underlying errors.
 
 @result   The format is (domain:code)(domain:code)…, where the first
 (domain,code) pair is the topmost, and later pairs are underlying errors.
 */
- (NSString*)deepSummary ;

@end
