#import "NSNumber+SomeMore.h"

@implementation NSNumber (SomeMore)

- (NSNumber*)negateBoolValue {
	return [NSNumber numberWithBool:![self boolValue]] ; 
}

- (NSNumber*)plus1 {
	return [NSNumber numberWithInteger:([self integerValue] + 1)] ;
}

@end
