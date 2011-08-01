#import <Cocoa/Cocoa.h>

@interface NSString (MorePaths) 

/*!
 @brief    Returns a replica of the receiver with a given suffix
 appended to the base part of the filename.

 @details  The suffix is inserted before the last dot "." in the
 last path component which begins the extension.
 Example: Assume suffix = "~" and self is "/Users/you/MyFile.gz.zip".
 This method returns "/Users/you/MyFile.gz~.zip"
*/
- (NSString*)pathBySuffixingFilenameWithString:(NSString*)suffix ;

/*!
 @brief    Returns whether or not NSFileManager can read a file at 
 the receiver, interpreted as a unix path.&nbsp;  Not recommended!
 @details  Unfortunately, NSFileManager does not give a reason.&nbsp; 
 Pre-testing file accessibility like this is a bad practice and this
 method is not recommended for new (Leopard) designs.&nbsp;  Use the
 newer NSFileManager methods that return errors and recover
 intelligently after a failure instead of pre-testing.
 @param    error_p  If you want an error (which just says that
 the NSFileManager says it ain't writable, pass an NSError**.
 Otherwise, pass NULL
 @result   YES if NSFileManager says it can write, NO if not.
 */
- (BOOL)pathIsReadableError_p:(NSError**)error_p ;

/*!
 @brief    Returns whether or not NSFileManager can write a file at 
 the receiver, interpreted as a unix path.&nbsp;  Not recommended!

 @details  Unfortunately, NSFileManager does not give a reason.&nbsp; 
 Pre-testing file accessibility like this is a bad practice and this
 method is not recommended for new (Leopard) designs.&nbsp;  Use the
 newer NSFileManager methods that return errors and recover
 intelligently after a failure instead of pre-testing.
 @param    error_p  If you want an error (which just says that
 the NSFileManager says it ain't writable, pass an NSError**.
 Otherwise, pass NULL
 @result   YES if NSFileManager says it can write, NO if not.
*/
- (BOOL)pathIsWritableError_p:(NSError**)error_p ;

- (BOOL)isDirectory ;
- (NSArray*)directoryContents ;
- (NSArray*)directoryContentsAsFullPaths ;

/*!
 @brief    Assuming the receiver is in someone's Home folder,
 returns the part of the path up to and including the Home folder.

 @details  There are three possible cases
 Case 1.  We're on the startup disk.  Example:
 >     /Users/jk/path/to/self
 >     will return: /Users/jk
 Case 2.  We're on a mounted network disk.  Example:
 >     /Volumes/AlPbHD/Users/bh/path/to/self
 >     will return: /Volumes/AlPbHD/Users/bh
 Case 3.  We're on a mounted network home directory.  Example:
 >     /Volumes/bh/path/to/self
 >     will return: /Volumes/bh
 @result   A POSIX path
 */
- (NSString*)parentHomePath ;

/*!
 @brief    Returns the POSIX path to the Library folder
 for a given homePath, which defaults to the current user's home.
 
 @details  If homePath is nil, this method uses the 
 NSSearchPathForDirectoriesInDomains() function
 recommended by Apple for finding the Application Support folder
 for the current user.  Otherwise, this method uses my own
 kludge which simply tacks on /Library.
 @param    homePath  The path to the Home Folder for which the
 Application Support path is desired, or nil if the path to the
 current user's Application Support is desired.
 */
+ (NSString*)libraryPathForHomePath:(NSString*)homePath ;

/*!
 @brief    Returns the POSIX path to the Application Support folder
 for a given homePath, which defaults to the current user's home.

 @details  If homePath is nil, this method uses the 
 NSSearchPathForDirectoriesInDomains() function
 recommended by Apple for finding the Application Support folder
 for the current user.  Otherwise, this method uses my own
 kludge which simply tacks on /Library/Application Support.
 @param    homePath  The path to the Home Folder for which the
 Application Support path is desired, or nil if the path to the
 current user's Application Support is desired.
 */
+ (NSString*)applicationSupportPathForHomePath:(NSString*)homePath ;

/*!
 @brief    Returns the path of a subfolder in the current user's
 Application Support folder with the same name as this application.

 @details  Example: "/Users/me/Library/Application Support/MyApp"
*/
+ (NSString*)applicationSupportFolderForThisApp ;

/*!
 @brief    Returns the POSIX path to the Preferences folder
 for a given homePath

 @details  Because this method supports Home paths on different
 Mac accounts, and even on different Macs, this method does not
 use the NSSearchPathForDirectoriesInDomains() function recommended
 by Apple to find the user's or system's special directories.
 @param    homePath  The path to the Home Folder for which the
 Application Support path is desired.
 Note that this is not usually the proper way to access preferences.
 You should usually use CFPreferences or NSUserDefaults.  This
 method is useful for special purposes.
 */
+ (NSString*)preferencesPathForHomePath:(NSString*)homePath ;

- (NSString*)displayPathName ;

- (NSArray*)pathAncestorsUpTo:(NSString*)tooHighAncestor  ;

/*!
 @brief     Returns whether or not the receiver, interpreted as
 a filesystem path, is a descendant of a given target path.

 @details   Example: If target is: @"/Users/jk/Docs/MyDocs"
 will return YES if self is: @"/Users/jk"
 will return YES if self is: @"/Users/jk/Docs/MyDocs"
 @param     target  The target path.  If nil, this method
 returns NO.
*/
- (BOOL)pathIsOrIsAncestorOf:(NSString*)target ;

/*!
 @brief    

 @details   Example: If target is: @"/Users/jk"
 will return YES if self is: @"/Users/jk/Docs"
 will return YES if self is: @"/Users/jk/Docs/MyDocs" 
 
*/
- (BOOL)pathIsDescendantOf:(NSString*)target ;

/*!
 @brief    Wrapper around pathIsDescendantOf but returns 
 NSNumber with value YES or NO instead of a BOOL
*/
- (NSNumber*)returningGlobalObjectYESNOPathIsDescendantOf:(NSString*)target ;


/*!
 @brief    

 @details  Returns empty string if path separator "/" is not found
*/
- (NSString*)pathRelativeToFirstComponent ;

/*!
 @brief    

 @details    Useful if self is a file system path
 return nil if self does not exist as path or is not a directory.
 returns empty array if self is a good directory but has no children
 if fullNotRelative is NO, returns paths relative to self
 Convert a slash-delimited POSIX path to a colon-delimited HFS path.
 As needed for AppleScripts
 
 @param    fullNotRelative  
 @param    excludePaths  
 @param    excludeNames  
 @result   
*/
- (NSArray*)directoryContentsAsFullPaths:(BOOL)fullNotRelative
							excludePaths:(NSArray*)excludePaths
							excludeNames:(NSArray*)excludeNames ;

- (NSString*)hfsPath ;


/*!
 @brief    Returns a unique filename in a given directory based
 on the receiver, truncated as desired, or nil if truncation is
 necessary but you indicate not OK to botch.

 @details  Make sure that the receiver includes the "extension"
 part of the filename; otherwise it cannot be properly tested
 for uniqueness in the given directory.
 
 Note that 34 characters is about how many will fit into the filename
 text field in NSSave Panel, with some margin -- unless there are many "m" chars.

 If the receiver contains all characters that are legal
 for filenames in Unix and Mac classic filesystems (which means
 all printing ASCII characters, plus the space character, minus
 the forward slash and minus the colon), and does not exceed the
 given maximumLength, and a file with the receiver does not
 already exist in the given path, the receiver is returned.&nbsp; 
 Illegal characters, if any, are replaced with a dash, "-".
 If truncation is necessary to avoid exceeding the maximum length,
 the filename, not including the extension,  is chopped about two
 thirds of the way through and two dashes, "--" are inserted at
 that location.&nbsp; If modification is necessary to make the
 name unique, a decimal number is appended.
 If all the given constraints cannot be satisfied using these
 algorithms, nil is returned.

 @param    maximumLength  The maximum number of characters
 allowed in the result.&nbsp; For no maximum, pass NSNotFound.
 @param    path  The directory in which the result must be a 
 unique filename, or nil if this is not a requirement.
 @param    truncateOk  YES if it is OK to to truncate the
 result by inserting two dashes about two-thirds of the way
 through if necessary to meet the maximumLength requirement,
 NO if you would rather have nil returned in this case.
 @result   The filename, usually an autoreleased copy of the
 receiver, sometimes not, modified, and, on rare occasions,
 nil.
*/
- (NSString*)uniqueFilenameInDirectory:(NSString*)path
							 maxLength:(int)maxLength 
							truncateOk:(BOOL)truncateOk ;

/*!
 @brief    Assuming that the receiver is a child path of
 /Volumes, returns a truncated copy of the receiver which is
 the path to the volume in which it resides, i.e.
 "/Volumes/MyVolume".

 @details  If the receiver has less than three path components,
 or if the first two components are not "/" and "Volumes"
 respectively, returns nil.  The method will always return either
 nil or a path with 3 components.
*/
- (NSString*)volumePath ;

/*!
 @brief    Assuming that the receiver is a file path, returns a file
 path which is like the receiver except with just enough tilde(s) (~)
 inserted just before the extension separator to make a path which 
 does not currently exist in the filesystem.
*/
- (NSString*)tildefiedPath ;

/*!
 @brief    Same as tildefiedPath except inserts hash characters (#)
 instead of tildes.
 */
- (NSString*)hashifiedPath ;

@end

