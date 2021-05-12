#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (MoreTypes)

- (void)setColor:(NSColor*)aColor
		  forKey:(NSString*)aKey ;

- (NSColor*)colorForKey:(NSString*)aKey ;

/*!
 @brief    Copies a color in User Defaults which was produced with the
 deprecated (in macOS 10.13) method +[NSArchiver archivedDataWithRootObject:],
 such as those produced by previous versions of this method, and writes it to
 a new key, using a secure coding method
 +[NSKeyedArchiver archivedDataWithRootObject:requiringSecureCoding:error:]
 which is readable using -colorForKey: in this version.
 
 @details  This method should be used to upgrade users' User Defaults when
 first shipping a version of your app with this version.  We create a new key
 instead of overwriting the value in the old key in case some users later
 downgrade to the previous version, which will be unable to read the new value.
 */
- (void)upgradeDeprecatedArchiveDataForOldKey:(NSString*)oldKey
                                       newKey:(NSString*)newKey;

@end
