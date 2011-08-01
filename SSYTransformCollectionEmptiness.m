#import "SSYTransformCollectionEmptiness.h"
#import "SSY+Countability.h"

@implementation SSYTransformCollectionNotEmpty

+ (Class)transformedValueClass {
    return [NSNumber class] ;
}

+ (BOOL)allowsReverseTransformation {
    return NO ;
}

- (id)transformedValue:(NSObject <SSYCountability> *)collection {
	BOOL booly = [collection count] > 0 ;
	return [NSNumber numberWithBool:booly] ;
}

@end


#if 0
NOT USED AT THIS TIME
@implementation SSYTransformCollectionIsEmpty

+ (Class)transformedValueClass {
    return [NSNumber class] ;
}

+ (BOOL)allowsReverseTransformation {
    return NO ;
}

- (id)transformedValue:(NSObject <SSYCountability> *)collection {
	BOOL booly = [collection count] == 0 ;
	return [NSNumber numberWithBool:booly] ;
}

@end
#endif