#import "SSYTransformMaxUIntegerToEmptyString.h"


@implementation SSYTransformMaxUIntegerToEmptyString

+ (Class)transformedValueClass {
    return [NSString class] ;
}

+ (BOOL)allowsReverseTransformation {
    return NO ;
}

- (id)transformedValue:(id)number {
	if ([number unsignedIntValue] == NSUIntegerMax) {
		return @"" ;
	}
	else {
		return [NSString stringWithFormat:@"%u", [number unsignedIntValue]] ;
	}
}

@end
