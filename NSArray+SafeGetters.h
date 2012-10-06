#import <Cocoa/Cocoa.h>


@interface NSArray (SafeGetters)

- (id)firstObjectSafely ;

- (id)lastObjectSafely ;

- (id)objectSafelyAtIndex:(NSInteger)index ;

@end
