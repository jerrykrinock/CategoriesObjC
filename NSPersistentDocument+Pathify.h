#import <Cocoa/Cocoa.h>

/*!
 @brief    Name of notification which is posted after a document is attempted
*/
extern NSString* const SSYDocumentDidSaveNotification ;



/*!
 @brief    One of the keys in the userInfo of an SSYDocumentDidSaveNotification,
 whose value is an NSNumber BOOL indicating whether or not the save operation
 succeeded
*/
extern NSString* const SSYDocumentDidSucceed ;

/*!
 @brief    One of the keys in the userInfo of an SSYDocumentDidSaveNotification,
 whose value is an NSNumber indicating the type of save operation.
 
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
 
 Suggested tooltip for the "Save As Move..." menu item:
 "This is like 'Save As...', except your document file will
 also be removed from its current name/location."
 
 @param    directory  path to the directory which will
 be initially shown in the dialog.
*/
- (void)saveAsMoveToDirectory:(NSString*)parentPath ;

/*!
 @brief    Action method for a "Save As Move..."
 item in the "File" menu, which also allows setting the
 initial directory in the dialog
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

/*!
 @brief    Same as saveMoveToNewUrl:error_p except
 does not perform the save operation and copies the
 old file -- does not delete it.
*/
- (BOOL)copyToNewUrl:(NSURL*)newUrl
			 error_p:(NSError**)error_p ;

@end
