#import <Cocoa/Cocoa.h>

/*
 @brief    Replacement for deprecated -convertScreenToBase:
 @details  Why does Apple deprecate stuff you need without providing a
 replacement?  I do agree that -convertScreenToBase: was poorly named! */
@interface NSWindow (Screening)

- (NSPoint)pointFromScreenPoint:(NSPoint)screenPoint ;

@end
