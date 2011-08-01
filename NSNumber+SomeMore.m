#import "NSNumber+SomeMore.h"

@implementation NSNumber (SomeMore)

- (NSNumber*)negateBoolValue {
	return [NSNumber numberWithBool:![self boolValue]] ; 
}

- (NSNumber*)plus1 {
	return [NSNumber numberWithInt:([self intValue] + 1)] ;
}

@end
