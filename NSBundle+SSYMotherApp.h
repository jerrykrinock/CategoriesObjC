#import <Foundation/Foundation.h>

@interface NSBundle (SSYMotherApp)

/*!
 @brief    Returns the string value of key "SSYMotherAppName" in the info
 dictionary of the current application's main bundle
 
 @details  If the key "SSYMotherAppName" does not exist, returns nil.
 */
- (NSString*)motherAppName ;

/*!
 @brief    Returns a bundle identifier obtained by replacing the last
 "dot" component in the receiver's bundle identifier with the string value of
 the key "SSYMotherAppName" in the info dictionary of the current application's
 main bundle
 
 @details  If the key "SSYMotherAppName" does not exist, returns nil.
 */
- (NSString*)motherAppBundleIdentifier ;

/*!
 @brief    Returns the full path to a (possibly nonexistent) folder in the
 current user's Application Support directory whose name is the string value
 of key "SSYMotherAppName" in the info dictionary of the current application's
 main bundle
 
 @details  If the key "SSYMotherAppName" does not exist, uses instead the value
 of "CFBundleName", and if that does not exist, simply returns the path to the
 user's Application Support directory.
 */
- (NSString*)applicationSupportPathForMotherApp ;

@end
