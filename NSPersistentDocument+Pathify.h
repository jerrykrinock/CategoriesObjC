#import <Cocoa/Cocoa.h>

extern NSString* const SSYPersistentDocumentPathifyErrorDomain ;

#define SSYPersistentDocumentPathifyErrorDestinationSameAsSource 157159
#define SSYPersistentDocumentPathifyErrorCouldNotOpenOldStore 157161
#define SSYPersistentDocumentPathifyErrorCouldNotSaveManagedObjectContext 157162
#define SSYPersistentDocumentPathifyErrorCouldNotDeleteOldStore 157163
#define SSYPersistentDocumentPathifyErrorCouldNotMoveStore 157164
#define SSYPersistentDocumentPathifyErrorCouldNotCopyStore 157165
#define SSYPersistentDocumentPathifyErrorCouldNotSaveStore 157166


@protocol NSPersistentDocumentMoveToStringer

/*!
 @brief    Implemented by a subclass of NSPersistentDocument including 
 the NSPersistentDocument+Pathify category to return, in the dialog presented
 by -saveAsMoveToDirectory:::, the localized string which appears in small
 font at the top of the dialog

 @details  Actually, see -[NSSavePanel setMessage:].
*/
- (NSString*)saveAsMoveMessage ;

/*!
 @brief    Implemented by a subclass of NSPersistentDocument including 
 the NSPersistentDocument+Pathify category to return, in the dialog presented
 by -saveAsMoveToDirectory:::, the localized string which appears to the
 left of the text field wherein the user enters the file name.
 
 @details  Actually, see -[NSSavePanel setNameFieldLabel:].
 */
- (NSString*)saveAsMoveLabel ;

/*!
 @brief    Implemented by a subclass of NSPersistentDocument including 
 the NSPersistentDocument+Pathify category to return, in the dialog presented
 by -saveAsMoveToDirectory:::, the localized string which appears in the
 default button
 
 @details  Actually, see -[NSSavePanel setPrompt:].
 */
- (NSString*)saveAsMovePrompt ;

@end


/*!
 @brief    Name of notification which you may post after a document is saved or
 atttempted to be saved.
 
 @details  This constant is not used by this category; it's just provided for
 your use – you should post and observe.
 
 If you have adopted asyncrhonous saving in macOS 10.7 or later, and you
 post the notification in writeSafelyToURL::::, remember that it will be posted
 on a non-main thread.  To post it on a main thread, create the notification
 and then do something like this:
 * [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
 *                                                        withObject:notification
 *                                                     waitUntilDone:NO] ;
*/
extern NSString* const SSYDocumentDidSaveNotification ;



/*!
 @brief    One of the keys which you may set into the userInfo of an
 SSYDocumentDidSaveNotification, whose value is an NSNumber BOOL
 indicating whether or not the save operation succeeded.
*/
extern NSString* const SSYDocumentDidSucceed ;

/*!
 @brief    One of the keys which you may set into the userInfo of an
 SSYDocumentDidSaveNotification, whose value is an NSNumber indicating
 the type of save operation.
 
 @details  The possible values are the values in the enumeration NSSaveOperationType.
 */
extern NSString* const SSYDocumentSaveOperation ;


@interface NSPersistentDocument (Pathify)

/*!
 @brief    Guts of an action method for a "Save As Move..."
 item in the "File" menu, which also allows setting the
 initial directory in the dialog

 @details  Presents a dialog which allows the user to 
 move the receiver's file to a new path, deleting the
 old file, then if the user responds affirmatively,
 invokes -saveMoveToNewUrl:error_p.
 
 In the dialog presented to the user, unless overidden
 by a non-nil parameter, the small text at the
 top ("message"), the text to the left of the filename
 text field ("label") and the text on the default button
 ("prompt") may be defined by implementing one or more of
 the methods in the NSPersistentDocumentMoveToStringer
 informal protocol in the receiver.
 
 Suggested tooltip for such a "Save As Move..." menu item:
 "This is like 'Save As...', except your document file will
 also be removed from its current name/location."
 
 @param    directory  path to the directory which will
 be initially shown in the dialog.
 @param    message  If not nil, in the dialog presented to
 the user, the string passed here will override the string
 returned by -saveAsMoveMessage and will appear as the
 the small text at the top, as in -[NSSavePanel setMessage:].
 @param    doneInvocation  An invocation which will be
 invoked after the operation has either been cancelled or
 completed.  May be nil.
*/
- (void)saveAsMoveToDirectory:(NSString*)parentPath
					  message:(NSString*)message
			   doneInvocation:(NSInvocation*)doneInvocation ;

/*!
 @brief    Action method for a "Save As Move..."
 item in the "File" menu
 
 @details  This method invokes -saveAsMoveToDirectory:::
 with all parameters nil.
*/
- (IBAction)saveAsMove:(id)sender ;

/*!
 @brief    Same as saveMoveToNewUrl:error_p: except that
 this method handles if an error occurs by presenting it
 with -[self presentError:].
*/
- (void)saveMoveToNewUrl:(NSURL*)newUrl ;

/*!
 @brief    Saves the receiver's file to a new file URL,
 changing the receiver's -fileURL, and deleting the old file.

 @param    error_p  Pointer to an NSError which, if not
 NULL and the method fails, will point to an NSError
 explaining the failure.&nbsp;  Pass NULL if you are
 not interested in the NSError.
 @result   YES if the method succeeds, NO if it fails.
*/
- (BOOL)saveMoveToNewUrl:(NSURL*)newUrl
				 error_p:(NSError**)error_p ;

@end
