#import "SSYTransformShortToBool.h"


@implementation SSYTransformShortToBool

+ (Class)transformedValueClass {
    return [NSNumber class] ;
}

+ (BOOL)allowsReverseTransformation {
    return YES ;
}

- (id)transformedValue:(id)shorty {
	short shortValue = [shorty shortValue] ;
	BOOL boolValue = (shortValue > 0) ;
	return [NSNumber numberWithBool:boolValue] ;
}

- (id)reverseTransformedValue:(id)booly {
	BOOL boolValue = [booly boolValue] ;
	short shortValue = boolValue ? 1 : 0 ;
	return [NSNumber numberWithShort:shortValue] ;
}

@end