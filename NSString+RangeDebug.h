#import <Cocoa/Cocoa.h>

// UNFORTUNATELY THIS SEEMS TO NOT WORK for detecting bad ranges, at least in Snow Leopard.
// My replacement -substringWithRange: DOES run if the range is OK, but if the range is
// not OK, the exception is raised by Cocoa first, and the method itself never runs.

// Probably what happens is that Cocoa's bad-range detector is wired in to execute before
// -substringWithRange: is invoked.  Oh well, this was a nice try!

#define NSSTRING_RANGE_DEBUG 0

#if NSSTRING_RANGE_DEBUG
#warning  Compiling with NSString (RangeDebug)

@interface NSString (RangeDebug)

@end

#endif