#import "NSObject+DeepCopy.h"
#import "NSObject+MoreDescriptions.h"

SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskCopy = 1 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskMutable = 2 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskEncodeable = 4 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskSerializable = 8 ;

@implementation NSObject (DeepCopy)

- copyLeafStyle:(SSYDeepCopyStyleBitmask)style {
	BOOL isEncodeable = NO ;
	
	// For efficiency, we only do this if it is relevant.
	if ((style & SSYDeepCopyStyleBitmaskEncodeable) != 0) {
		if ([self respondsToSelector:@selector(encodeWithCoder:)]) {
			// It *may* be encodeable.
			isEncodeable = YES ;
			// Just because an object conforms to NSCoding or responds to encodeWithCoder:
			// doesn't mean that it's encodeable.  Example: An NSError with nonencodeable
			// objects in its userInfo dictionary.  The only way to find out if it's
			// ^really^ encodeable is to try encoding it and see if an exception is raised
			@try {
				[NSKeyedArchiver archivedDataWithRootObject:self] ;
			}
			@catch (id anyException) {
				// Unfortunately, Cocoa will log an *** exception
				// saying that something bad happened.  So we log
				// a message to explain that
				NSLog(@"Howdy.  The above exception, and the one which follows, "
				@"are expected behavior in testing for encodeability: %@.  "
				@"It's not a bug.  Just ignore it.",
				[self class]) ;
				isEncodeable = NO ;
			}
		}
	}	
	
	if(
	   ((style & SSYDeepCopyStyleBitmaskSerializable) != 0) 
	   &&
	   ![NSPropertyListSerialization dataFromPropertyList:self
												   format:NSPropertyListBinaryFormat_v1_0
										 errorDescription:NULL]
	   ) {
		// Invoker specified serializable but self is not serializable.
		// Return a description
		return [[self longDescription] retain] ;
	}
	else if(
			((style & SSYDeepCopyStyleBitmaskEncodeable) != 0) 
			&&
			!isEncodeable
			) {
		// Invoker specified encodeable but self is not encodeable
		// Return a description
		return [[self longDescription] retain] ;
	}
	else if(
			((style & SSYDeepCopyStyleBitmaskMutable) != 0) 
			&&
			[self respondsToSelector:@selector(mutableCopyWithZone:)]
			) {
		// Invoker specified mutable and self is mutable
		// Return a mutable copy
		return [self mutableCopy] ;
	}
	else if(
			((style & SSYDeepCopyStyleBitmaskCopy) != 0) 
			&&
			[self respondsToSelector:@selector(copyWithZone:)]
			) {
		// Invoker specified copy and self is copyable
		// Return a copy
		return [self copy];
	}
	else {
		// Return self
		return [self retain] ;
	}
}

- mutableCopyDeepStyle:(SSYDeepCopyStyleBitmask)style {
	if (
		[self respondsToSelector:@selector(mutableCopyWithZone:)]
		&&
		[self respondsToSelector:@selector(count)]) {
		return [self mutableCopy] ;
	}
	else {
		return [self copyLeafStyle:style] ;
	}
	
	// Supress compiler warning
	return nil ;
}

- (NSDictionary*)mutableCopyDeepPropertyList {
	id copy = (NSMutableDictionary*)CFPropertyListCreateDeepCopy(
																 kCFAllocatorDefault,
																 (CFPropertyListRef)self,
																 kCFPropertyListMutableContainers
																 ) ;
	return copy ;
}

@end

@implementation NSDictionary (DeepCopy)

- mutableCopyDeepStyle:(SSYDeepCopyStyleBitmask)style {
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];

    for (id key in self) {
		id object = [self objectForKey:key] ;
        id copy = [object mutableCopyDeepStyle:style] ;
        [newDictionary setObject:copy
						  forKey:key] ;
        [copy release] ;
    }
    return newDictionary;
}

@end


@implementation NSArray (DeepCopy)

- mutableCopyDeepStyle:(SSYDeepCopyStyleBitmask)style {
   NSMutableArray *newArray = [[NSMutableArray alloc] init] ;
    for (id object in self) {
		id copy = [object mutableCopyDeepStyle:style] ;
        [newArray addObject:copy];
        [copy release];
    }
    return newArray;
}

@end


@implementation NSSet (DeepCopy)

- mutableCopyDeepStyle:(SSYDeepCopyStyleBitmask)style {
    NSMutableSet *newSet = [[NSMutableSet alloc] init];
    for (id object in self) {
		id copy = [object mutableCopyDeepStyle:style] ;
        [newSet addObject:copy];
        [copy release];
    }
    return newSet;
}

@end