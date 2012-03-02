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
 @brief    Gets an FSRef structure defining a given file URL.

 @details  A Cocoa wrapper around FSPathMakeRef().
 Warning: FSPathMakeRef may hang for a minute or so if the
 given path is on a mounted server and the connection is
 interrupted.
 @param    url  A file URL whose FSRef is desired
 @param    fsRef_p  On output, if no error occurred, will point
 to an FSRef structure defining the given file URL.
 @param    error_p  Pointer which will, upon return, if an error
 occured and said pointer is not NULL, point to an NSError
 describing said error.
 @result   YES if the operation succeeded in getting an FSRef,
 NO otherwise.
*/
- (BOOL)getFromUrl:(NSURL*)url
		   fsRef_p:(FSRef*)fsRef_p
		   error_p:(NSError**)error_p ;

/*!
 @brief    Swaps the contents of the files given by two file URLs.

 @details  See FSExchangeObjects() since this is a Cocoa wrapper
 around that function and FSPathMakeRef().
 
 Warning: FSPathMakeRef may hang for a minute or so if the
 given file URL is on a mounted server and the connection is
 interrupted.

 According to Chris Parker of Apple, this function is provided by
 -replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:.
 But it requires Mac OS 10.6.
 
 @param    url1  A file URL whose contents is to be swapped
 @param    url2  A file URL whose contents is to be swapped
 @param    error_p  Pointer which will, upon return, if an error
 occured and said pointer is not NULL, point to an NSError
 describing said error.
 @result   YES if the operation succeeded in getting an FSRef,
 NO otherwise.
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
 @brief    Returns the modification date when the receiver is a
 filesystem path.
 
 @details  Follows symbolic links.&nbsp;
 */
- (NSDate*)modificationDateForPath:(NSString*)path ;

/*!
 @brief    Creates a directory if none exists at a given path.

 @details  If a regular file is found at the given path, it is deleted
 and replaced with the new directory.
 @param    error_p  A pointer, or nil.&nbsp; If non-nil, on output, if an
 error occurred, points to the relevant NSError.  
 @result   YES if the directory already exists or was successfully
 created; NO otherwise.
*/
- (BOOL)createDirectoryIfNoneExistsAtPath:(NSString*)path
								  error_p:(NSError**)error_p ;

/*!
 @brief    Returns YES if a file or directory exists at a given
 path and is not in a temporary or Trash folder, or is probably in
 the "Dropbox trash", meaning that it has ".dropbox.cache" as one
 of its path components.  Otherwise, returns NO.
 
 @details  Until Dropbox version 2, I could look inside the Dropbox
 database, find where the Dropbox folder is, and do this exactly.
 Currently, this method will turn NO for any path which contains
 ".dropbox.cache" as one of its path components.
 */
- (BOOL)fileIsPermanentAtPath:(NSString*)path ;

/*!
 @brief    Tests to see whether or not a file at a given path in
 the filesystem is locked.

 @details  
 @param    error_p  Pointer which will, upon return, if an error
 occurred and said pointer is not NULL, point to an NSError
 describing said error.
 @result   NSOnState if the path is locked, NSOffState if the path
 is not locked, NSMixedState if the locked/unlocked status could not
 be determined due to an error.
*/
- (NSInteger)fileIsLockedAtPath:(NSString*)path
						error_p:(NSError**)error_p ;


/*!
 @brief    Another method to determine if a file is locked, based
 on fcntl(2).

 @details  See which one works better for you!
*/
- (BOOL)fcntlIsLockedAtPath:(NSString*)path ;


/*!
 @brief    Attempts to lock or unlock, as directed, a given path
 in the filesystem.

 @details  
 This method ignores the current locked/unlocked status -- it
 simply overwrites it.
 @param    doLock  YES to lock the file, NO to unlock.
 @param    error_p  Pointer which will, upon return, if an error
 occurred and said pointer is not NULL, point to an NSError
 describing said error.
 @result   YES if the operation completed successfully, NO
 otherwise. */
- (BOOL)setDoLock:(BOOL)doLock
	   fileAtPath:(NSString*)path
		  error_p:(NSError**)error_p ;

/*!
 @brief    Returns the path a special folder of a given type

 @details  This is a Cocoa wrapper around FSFindFolder().
 @param    folderType  The OSType of the desired folder.
 See documentation of Apple's FSFindFolder, 2nd argument.
 Examples: kTrashFolderType, kDesktopFolderType.
 @result   Path to the desired folder, or nil if it could not
 be found.  This path will NOT have a trailing slash UNLESS
 the path is the root, i.e. @"/".
*/
- (NSString*)pathToSpecialFolderType:(OSType)folderType ;

/*!
 @brief    A variation on the -removeItemAt…:… methods which (a) does not return
 an error if the item at the given path does not exist and (b) adds a recovery
 suggestion, that the user try to do the remove "manually".
*/
- (BOOL)removeThoughtfullyPath:(NSString*)path
					   error_p:(NSError**)error_p ;

/*!
 @brief    Trashes a given path by telling the Finder to do it with AppleScript

 @details  The Finder will play the trash sound if successful
 @param    error_p  If not NULL and if an error occurs, upon return,
           will point to an error object encapsulating the error.
 @result   YES if the method completed successfully, otherwise NO
*/
- (BOOL)trashPath:(NSString*)path
		  error_p:(NSError**)error_p ;


@end


#if 0
// TEST CODE FOR FILE LOCK METHODS

#import <Cocoa/Cocoa.h>
#import "NSFileManager+SomeMore.h"
#import "NSError+SSYAdds.h"

int main(int argc, const char *argv[]) {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init] ;
	
	if (argc != 2) {
		NSLog(@"This program requires 1 parameter, a unix path.  Sorry!") ;
		exit (1) ;
	}
	
	// argv[0] is the command line.  Read the next one.
	NSString* path = [NSString stringWithUTF8String:argv[1]] ;  
	NSLog(@"Subject file: %@", path) ;
	
	char command = 'r' ;
	NSInteger intResult ;
	NSError* error = nil ;
	
	while (command != 'q') {
		BOOL ok = YES ;
		switch (command) {
			case 'r':
				intResult = [[NSFileManager defaultManager] fileIsLockedAtPath:path
																	   error_p:&error] ;
				switch (intResult) {
					case NSMixedState:
						ok = NO ;
						break ;
					case NSOnState:
						NSLog(@"File is locked.") ;
						break ;
					case NSOffState:
						NSLog(@"File is not locked.") ;
				}
				
				break ;
				
			case 'l':
			case 'u':
				ok = [[NSFileManager defaultManager] setDoLock:(command == 'l')
													fileAtPath:path
													   error_p:&error] ;
				break ;
			case 'q':
				break ;
		}
		
		if (!ok) {
			NSLog(@"Sorry, error occured:\n%@", [error longDescription]) ;
		}
		
		NSLog(@"Enter one of r=reread, l=lock, u=unlock, q=quit.  Then hit 'return'.") ;
		command = getchar() ;
		// Get and discard the 'return' character
		getchar() ;
	}
	
	[pool release] ;
	
	return 0 ;
}

#endif
