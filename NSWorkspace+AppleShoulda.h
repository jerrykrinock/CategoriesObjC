#import <Cocoa/Cocoa.h>


/*!
 @brief    Methods which Apple should have provided in NSWorkspace
*/
@interface NSWorkspace (AppleShoulda) 

+ (NSString*)appNameForBundleIdentifier:(NSString*)bundleIdentifier ;

+ (NSString*)bundleIdentifierForAppName:(NSString*)appName ;

- (NSArray*)mountedLocalVolumeNames ;

@end
