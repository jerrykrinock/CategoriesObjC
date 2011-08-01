#import <objc/runtime.h>
#import "NSString+RangeDebug.h"

#if NSSTRING_RANGE_DEBUG

@implementation NSString (RangeDebug)

+ (void)load {
	// Swap the implementations of one method with another.
	// When the message Xxx is sent to the object (either instance or class),
	// replacement_Xxx will be invoked instead.  Conversely,
	// replacement_Xxx will invoke Xxx.
	
	// NOTE: Below, use class_getInstanceMethod or class_getClassMethod as appropriate!!
	NSLog(@"Replacing methods in %@", [self class]) ;
	Method originalMethod = class_getInstanceMethod(self, @selector(substringWithRange:)) ;
	Method replacedMethod = class_getInstanceMethod(self, @selector(replacement_substringWithRange:)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
}

- (NSString*)badRange {
	return @"OUT-OF-RANGE" ;
}

- (NSString*)replacement_substringWithRange:(NSRange)range {
	NSInteger min = range.location ;
	NSInteger max = range.location + range.length ;
	if (
		(min < 0)
		||
		(min > [self length])
		||
		(max < 0)
		||
		(max > [self length])
		) {
		NSLog(@"Requested substringWithRange %@ out of range for string of length %d.  Set breakpoint at -[NSString badRange] to debug if you don't recognize string:\n%@", NSStringFromRange(range), [self length], self) ;
		return [self badRange] ;
	}
	
	// Due to the swap, this calls the original method
	return [self replacement_substringWithRange:range] ;
}

@end

#endif