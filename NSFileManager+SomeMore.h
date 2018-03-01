#import <Cocoa/Cocoa.h>

extern NSString* const SSYMoreFileManagerErrorDomain ;

@interface NSFileManager (SomeMore)

/*!
 @brief    Attempts to remove the filesystem item at a given path
 without complaining if there is no such item.
 
 @param    error_p  
 @param    error_p  Pointer which will, upon return, if this method
 returns NO and said pointer is not NULL, point to an NSError
 describing said error.
 @result   YES if the item was removed, does not exist, or if
 the given path is nil.  NO only if the item exists but could
 not be removed.
*/
- (BOOL)removeIfExistsItemAtPath:(NSString*)path
						 error_p:(NSError**)error_p ;

/*!
 @brief    Swaps the contents and metadata of the files given by two file URLs
 so that the first URL ends up with the contents and metadata that was 
 originally in the second URL and vice versa

 @param    url1  A file URL whose contents is to be swapped
 @param    url2  A file URL whose contents is to be swapped
 @param    error_p  Pointer which will, upon return, if an error
 occured and said pointer is not NULL, point to an NSError
 describing said error.
 @result   YES if the operation succeeded, NO otherwise.
 */
- (BOOL)swapUrl:(NSURL*)url1
		withUrl:(NSURL*)url2
		error_p:(NSError**)error_p ;

/*!
 @brief    Changes the modification date of a given path to the current
 time and date

 @param    error_p  If not NULL and if an error occurs, upon return,
           will point to an error object encapsulating the error.
 @result   YES if the method completed successfully, otherwise NO
*/
- (BOOL)touchPath:(NSString*)path
		  error_p:(NSError**)error_p ;

/*!
 @brief    Returns the file modification date when the receiver is a
 filesystem path.
 
 @details  Follows symbolic links
 */
- (NSDate*)modificationDateForPath:(NSString*)path ;

/*!
 @brief    Returns the file creation date when the receiver is a
 filesystem path.
 
 @details  Follows symbolic links
 */
- (NSDate*)creationDateForPath:(NSString*)path ;

/*!
 @brief    Creates a directory if none exists at a given path.

 @details  If a regular file is found at the given path, it is deleted
 and replaced with the new directory.
 @param    error_p  A pointer, or nil.  If non-nil, on output, if an
 error occurred, points to the relevant NSError.  
 @result   YES if the directory already exists or was successfully
 created; NO otherwise.
*/
- (BOOL)createDirectoryIfNoneExistsAtPath:(NSString*)path
								  error_p:(NSError**)error_p ;

/*!
 @brief    Returns YES if a file or directory exists at a given
 path and is not in a temporary or Trash folder.  Otherwise, returns NO.
 
 @details  Starting in BookMacster 1.15.3, this method no longer returns YES
 if a document appears to be in a Dropbox cache/trash.
 */
- (BOOL)fileIsPermanentAtPath:(NSString*)path ;

/*!
 @brief    Returns the unix advisory lock status for a given path

 @result   Possible values are:
 -2  Some weird error
 -1  Could not open path, usually because it does not exist
 F_RDLCK Found a "Read" aka "Shared" lock
 F_UNLCK Found no lock
 F_WRLCK Found a "Write" aka "Exclusive" lock
*/
- (short)unixAdvisoryLockStatusForPath:(NSString*)path ;

/*!
 @brief    Returns the path a special folder of a given type

 @param    folderType  A member of the NSSearchPathDirectory enum declared in
 NSPathUtilities.h.  Example: NSTrashDirectory.
 @result   Path to the desired folder, or nil if it could not
 be found.  This path will NOT have a trailing slash UNLESS
 the path is the root, i.e. @"/".
*/
- (NSString*)pathToSpecialFolderType:(NSSearchPathDirectory)folderType ;

/*!
 @brief    A variation on the -removeItemAt…:… methods which (a) does not return
 an error if the item at the given path does not exist and (b) adds a recovery
 suggestion, that the user try to do the remove "manually".
*/
- (BOOL)removeThoughtfullyPath:(NSString*)path
					   error_p:(NSError**)error_p ;

/*!
 @brief    Trashes a given path

 @param    scriptFinder  If YES, tells the Finder to do it via AppleScript.
 The Finder will play the trash sound if successful.  If NO, uses
 -[NSWorkspace recycleURLs::]
 @param    error_p  If not NULL and if an error occurs, upon return,
 will point to an error object encapsulating the error.
 @result   YES if the method completed successfully, otherwise NO
 */
- (BOOL)trashPath:(NSString*)path
	 scriptFinder:(BOOL)scriptFinder
		  error_p:(NSError**)error_p ;


/*!
 @brief    Ensures that the user's Desktop contains a folder with a given
 name, creating one of necessary

 @details  This method is handy when you want to write some files to the
 user's Desktop, for debugging maybe.  It contains the couple dozen lines of
 tedious code, with error checking, which are necessary to do it robustly.

 @param    error_p  If not NULL and if an unsuccessful, upon return,
 will point to an error object encapsulating the error.
 @result   If successful, the full path to the target directory, otherwise nil
 */
- (NSString*)ensureDesktopDirectoryNamed:(NSString*)dirName
                                 error_p:(NSError**)error_p;

@end
