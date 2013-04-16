#import <Foundation/Foundation.h>

@interface NSError (SuggestMountVolume)

/*!
 @brief    If the receiver's -userInfo contains a value for key @"Path",
 and if this path begins with @"/Volumes/SomeVolume/", and if SomeVolume
 is apparently not mounted, returns a replica of the receiver with a
 localized recovery suggestion to mount SomeVolume added; otherwise,
 returns the receiver.
 */
- (NSError*)maybeAddMountVolumeRecoverySuggestion ;

@end
