#import <Cocoa/Cocoa.h>

extern NSString* const SSYAppleScriptErrorDomain ;

@interface NSError (LowLevel)
/*!
 @brief    Given a Mac OS X system error code, tries to return
 an error with one of the Mac OS X system domains and
 localized description.
 
 @details  If you give it a known combination of domain and code, 
 and nil userInfo, -[NSError errorWithDomain:code:userInfo:] will 
 sometimes fill in the localized description, at least for errors
 in NSOSStatusErrorDomain and NSMachErrorDomain.&nbsp;  This method
 tries to use that capability, but I need more documentation to 
 make it work better.
 @param    code  An error code returned by a system function
 */
+ (NSError*)errorWithMacErrorCode:(OSStatus) code ;

/*!
 @brief    Given a POSIX error code, such as errno, returns
 an error with NSPOSIXErrorDomain and maybe a
 localized description.
 
 @details  Uses +errorWithMacErrorCode: under the hood.
 @param    code  An error code returned by a system function
 */
+ (NSError*)errorWithPosixErrorCode:(OSStatus)code ;

+ (NSError*)errorWithHTTPStatusCode:(NSInteger)code 
					 prettyFunction:(const char*)prettyFunction ;

+ (NSError*)errorWithAppleScriptErrorDictionary:(NSDictionary*)dic ;

@end
