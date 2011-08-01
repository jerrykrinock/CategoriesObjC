#import <Cocoa/Cocoa.h>

/*!
 @brief    A transformer to transform a short to a BOOL, because
 I don't trust whatever bindings might do.&nbsp;  Transforms
 a value <= 0 to a NO and a >0 to YES.&nbsp;  Reverse-transforms
 YES to 1 and NO to 0.
 */
@interface SSYTransformShortToBool : NSValueTransformer {
}

@end
