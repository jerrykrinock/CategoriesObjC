#import "NSUserDefaults+MoreTypes.h"

@implementation NSUserDefaults (MoreTypes)

- (void)setColor:(NSColor *)color forKey:(NSString *)key {
    NSError* error = nil;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:color
                                         requiringSecureCoding:YES
                                                         error:&error];
    if (error) {
        NSLog(@"Internal error 382-5849 archiving color for key %@ in user defaults.", key);
    }
    [self setObject:data forKey:key] ;
}

- (NSColor*)colorForKey:(NSString *)key {
    NSColor* color = nil ;
    NSData* data = [self dataForKey:key] ;
    if (data != nil) {
        NSError* error = nil;
        color = (NSColor*)[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class]
                                                               fromData:data
                                                                  error:&error];
        if (error) {
            NSLog(@"Internal error 382-5850 unarchiving color for key %@ in user defaults.", key);
        }
    }
	
	return color ;
}

- (void)upgradeDeprecatedArchiveDataForOldKey:(NSString*)oldKey
                                       newKey:(NSString*)newKey {
    NSColor* color = nil ;
    NSData* data = [[NSUserDefaults standardUserDefaults] dataForKey:oldKey] ;
    if (data) {
        @try {
            // Sorry, Apple: Need to get old color with deprecated method
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            color = (NSColor*)[NSUnarchiver unarchiveObjectWithData:data] ;
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
        } @catch (NSException *exception) {
            NSLog(@"Exception upgrading color in user defaults for key %@, which was expected to be produced by +[NSArchiver archivedDataWithRootObject:]", oldKey);
        }
        if (!color || [color isKindOfClass:[NSColor class]]) {
            [self setColor:color
                    forKey:newKey];
        } else {
            NSLog(@"Error upgrading color in user defaults for key %@.  Expected NSColor, found %@", oldKey, [color className]);
        }
    }
}

@end
