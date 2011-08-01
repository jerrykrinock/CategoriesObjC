#import "NSObject+DoNil.h"

@implementation NSObject (DoNil)

+ (BOOL)isEqualHandlesNilObject1:(id)object1
						 object2:(id)object2 {
	BOOL isEqual = NO ;
	if (object1) {
		if (!object2) {
			// Documentation for -isEqual does not state if
			// the argument can be nil, so for safety I handle that
			// here, without invoking it.

			// object2 is nil but object1 is not
			// Leave isEqual as initialized, to NO.
		}
		else {
			isEqual = [object1 isEqual:object2] ;
		}
	}
	else if (object2) {
		// object1 is nil but object2 is not
		// Leave isEqual as initialized, to NO.
	}
	else {
		isEqual = YES ;
	}
	
	return isEqual ;
}

+ (id)fillIfNil:(id)object {
	return object ? object : @"object_is_nil" ;
}

- (BOOL)isDifferentValue:(id)value
			  forKeyPath:(id)key {
	return ![NSObject isEqualHandlesNilObject1:[self valueForKeyPath:key]
									   object2:value] ;
}

// Because this category is also used in Bookdog,
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5		

- (BOOL)isAnyDifferentValueInDictionary:(NSDictionary*)newValues {
	for (id key in newValues) {
		if ([self isDifferentValue:[newValues objectForKey:key]
						forKeyPath:key]) {
			return YES ;
		}
	}
	
	return NO ;
}

#endif

@end