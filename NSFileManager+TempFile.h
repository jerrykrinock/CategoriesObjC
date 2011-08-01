#import <Cocoa/Cocoa.h>


@interface NSFileManager (TempFile)

/*!
 @brief    Returns a file URL which is the same as a given URL
 except for the appending of at least one ".temp" filename
 extensions.
 
 @details  Additional ".temp" filename extensions are appended
 if the file URL created is that of a path which already
 exists in the fileysystem
 */
- (NSURL*)temporarySiblingForFileUrl:(NSURL*)fileUrl ;

/*!
 @brief    Composes and returns a path which may be used to 
 create a new, unique, temporary file.

 @details  The filename is of the form "processName|uuid"
 where processName is the processName given by NSWorkspace
 for the current process, and uuid is a compact uuid given by
 SSYUuid.  The filename is in the temporary directory
 returned by NSTemporaryDirectory().  There is no filename
 "extension".  (You can append one if you want one.)
*/
- (NSString*)temporaryFilePath ;

@end
