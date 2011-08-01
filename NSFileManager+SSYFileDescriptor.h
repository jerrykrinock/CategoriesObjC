#import <Cocoa/Cocoa.h>

extern NSString* const SSYFileManagerFileDescriptorErrorDomain ;

@interface NSFileManager (SSYFileDescriptor)

/*!
 @brief    Returns the path of a given file descriptor in a given
 process

 @details  Although it is much more efficient to remember the path
 of a file when you open it, this method is useful to find the new
 path to a file after it as been moved (renamed) by another process.
 @param    fileDescriptor  The file descriptor of the desired file
 @param    pid  The pid of the process which has the desired file open
with the given descriptor.  You may pass 0 to specify the current process.
 @param    error_p  If not NULL and if an error occurs, upon return,
 will point to an error object encapsulating what went wrong.
 @result   The full path to the file, or nil if an error occurred.
*/
+ (NSString*)pathForFileDescriptor:(NSInteger)fileDescriptor
							   pid:(pid_t)pid
						   error_p:(NSError**)error_p ;
	
@end
