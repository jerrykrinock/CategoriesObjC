#import "NSDictionary+Histogram.h"


#if 0
@implementation NSMutableDictionary (Histogram)

- (void)incrementIntegerValueForKey:(NSString*)key {
	id currentObject = [self objectForKey:key] ;
	NSInteger newValue ;
	if ([currentObject respondsToSelector:@selector(integerValue)]) {
		newValue = [(NSNumber*)currentObject integerValue] + 1 ;
	}
	else {
		newValue = 1 ;
	}
	
	[self setObject:[NSNumber numberWithInteger:newValue]
			 forKey:key] ;
}


@end
#endif
