#import <Foundation/Foundation.h>

/*
 @brief    Macro to make a simple error in domain +[NSError myDomain] which
 includes the name of the routine in which the error was created in its
 -userInfo
 
 @details  Adds the current routine name, from __PRETTY_FUNCTION__, as an
 object in the userInfo dictionary.
 
 @param    code__  NSInteger  The errorCode of the desired error
 @param    localizedDescription__  NSString*.  The localizedDescription of the
 desired error
 */
#define SSYMakeError(code__,localizedDescription__) [NSError errorWithLocalizedDescription:localizedDescription__ code:code__ prettyFunction:__PRETTY_FUNCTION__]

@interface NSError (MyDomain)

/*!
 @brief    Returns an error domain for the current process, which is used
 by the other error-generating methods in this category.
 
 @details  For applications, this will be the main bundle identifier.&nbsp;
 For processes that don't have an [NSBundle mainAppBundle], this will be the
 executable name, specifically the last path component of the process'
 first command-line argument.
 */
+ (NSString*)myDomain ;

/*!
 @brief    Method which underlies the SSYMakeError() macro.
 */
+ (NSError*)errorWithLocalizedDescription:(NSString*)localizedDescription
                                     code:(NSInteger)code
                           prettyFunction:(const char*)prettyFunction ;

@end
