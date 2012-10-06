#import "SSYTransformMaxUIntegerToEmptyString.h"


@implementation SSYTransformMaxUIntegerToEmptyString

+ (Class)transformedValueClass {
    return [NSString class] ;
}

+ (BOOL)allowsReverseTransformation {
    return NO ;
}

- (id)transformedValue:(id)number {
	if ([number unsignedIntegerValue] == NSUIntegerMax) {
		return @"" ;
	}
	else {
		return [NSString stringWithFormat:@"%qu", (unsigned long long)[number unsignedIntegerValue]] ;
	}
}

@end
