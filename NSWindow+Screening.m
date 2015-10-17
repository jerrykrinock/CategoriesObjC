#import "NSWindow+Screening.h"

@implementation NSWindow (Screening)

- (NSPoint)pointFromScreenPoint:(NSPoint)screenPoint {
    NSRect screenRect = NSZeroRect ;
    screenRect.origin = screenPoint ;
    NSRect pointRect = [self convertRectFromScreen:screenRect] ;
    NSPoint windowPoint = pointRect.origin ;
    return windowPoint ;
}

@end
