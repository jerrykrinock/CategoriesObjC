#import <Cocoa/Cocoa.h>


@interface NSArray (SafeGetters)

- (id)firstObjectSafely ;

- (id)lastObjectSafely ;

- (id)objectSafelyAtIndex:(int)index ;

@end
