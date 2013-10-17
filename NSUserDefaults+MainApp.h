#import <Foundation/Foundation.h>

/* 
 @brief    Methods based on CFPreferences, useful in a "helper" app or tool,
 which can read and write preferences in the "main" app relative to the current
 process, as defined by NSBundle(MainApp)

 @details  Note that these methods all implicitly sync the preferences
 after and/or before acting.  This is because it may be possible that main app
 and helper might be running simultaneously, affecting the same default values.
 You should do effectively the mirror this syncing: Remember to
 use -[NSUserDefaults synchronize] before reading and after writing user
 defaults which may be the subject of these methods in a helper.

 More generally, if you are indeed using these methods for interapplication
 communication, consider that unexpected results may occur if there are race
 conditions between these methods and NSUserDefaults setting and getting in
 the main app.
 
 Don't try this in the sandbox.  I think Apple will kick you out. :(
 */

@interface NSUserDefaults (MainApp)

- (id)syncAndGetMainAppValueForKeyPathArray:(NSArray*)keyPathArray ;

- (id)syncAndGetMainAppValueForKey:(NSString*)key ;

- (BOOL)syncAndGetMainAppBoolForKey:(NSString*)key ;

/*!
 @brief    Same as as setValue:forKeyPath: except allows you to set preferences
 for an application other than the current application.
 
 */
- (void)setAndSyncMainAppValue:(id)value
               forKeyPathArray:(NSArray*)keyArray ;

- (void)setAndSyncMainAppValue:(id)value
                        forKey:(NSString*)key ;

- (void)setAndSyncMainAppBool:(BOOL)value
                       forKey:(NSString*)key ;

- (void)removeAndSyncMainAppKey:(NSString*)innerKey
   fromDictionaryAtKeyPathArray:(NSArray*)keyPathArray ;

- (void)removeAndSyncMainAppKey:(NSString*)innerKey
            fromDictionaryAtKey:(NSString*)key ;

- (void)removeAndSyncMainAppKey:(NSString*)key ;

@end
