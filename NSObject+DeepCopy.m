#import "NSObject+DeepCopy.h"
#import "NSObject+MoreDescriptions.h"

SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskCopy = 1 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskMutable = 2 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskEncodeable = 4 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskSerializable = 8 ;

@implementation NSObject (DeepCopy)

/*!
 @details  This method now accomodates a behavior change which I noticed in
 Yosemite.  It might be in Yosemite, or in the Yosemite SDK.
 
 In the past, if I passed an object which was not encodeable, for example, an
 NSManagedObject, or a collection containing such an object, to
 -[NSKeyedArchiver archivedDataWithRootObject:], it would raise an exception
 and print a warning to the console.
 
 Now, if I pass it an unencodeable object, it instead happily returns an NSData
 object which will in turn happily return nil when passed to
 +[NSKeyedUnarchiver unarchiveObjectWithData:]. If I pass it a collection
 containing an unencodeable object, it also happily returns an NSData object,
 but this one, when passed to +[NSKeyedUnarchiver unarchiveObjectWithData:],
 will raise an exception complaining the count of objects is less than the
 count of keys.
 
 There is no mention of changed behavior in the Yosemite Foundation Release
 Notes.  The documentation of -[NSKeyedArchiver archivedDataWithRootObject:]
 has never made any mention of what happens if you pass it an unencodeable
 object, so, legally speaking, any behavior is “expected” :(
 */
- copyLeafStyle:(SSYDeepCopyStyleBitmask)style {
	BOOL isEncodeable = NO ;
	
	// For efficiency, we only do this if it is relevant.
	if ((style & SSYDeepCopyStyleBitmaskEncodeable) != 0) {
		if ([self respondsToSelector:@selector(encodeWithCoder:)]) {
			// It *may* be encodeable.
			isEncodeable = YES ;
			/* Just because an object conforms to NSCoding or responds to
             encodeWithCoder: doesn't mean that it's encodeable.  Example: An
             NSError with nonencodeable objects in its userInfo dictionary.  The
             only way to find out if it's ^really^ encodeable is to try encoding
             it and see if an exception is raised, and also test the encoded
             archive and see if it decodes to something which is not nil. */
			@try {
				NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:self] ;
                if (!archive) {
                    /* I've never seen this occur, but testing for it seems
                     reasonable, especially given the change in behavior that
                     occurred in OS X 10.10. */
                    isEncodeable = NO ;
                }
                else {
                    id unarchivedSelf = [NSKeyedUnarchiver unarchiveObjectWithData:archive] ;
                    if (!unarchivedSelf) {
                        /* This can occur in OS X 10.10 and later. */
                        isEncodeable = NO ;
                    }
                    else {
                        /* I've never seen this happen, but let's check one
                         more thing, in case Apple does something else weird
                         in some future OS X.  Actually, this about covers
                         all possibilities, because if the unarchived object
                         is equal to the pre-archived object, it is good by
                         definition.  The only thing we haven't covered is if
                         Apple decides to make -[[NSKeyedArchiver
                         archivedDataWithRootObject:] crash when passed an
                         unencodeable object. */
                        if (![self isEqual:unarchivedSelf]) {
                            isEncodeable = NO ;
                        }
                    }
                }
            }
			@catch (id anyException) {
                /* This can occur in OS X 10.9 and earlier.  Unfortunately,
                 Cocoa will log an *** exception saying that something bad
                 happened.  So we try to nullify that by logging a friendly
                 follow-on message to explain that this is nothing to worry
                 about. */
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
	   ![NSPropertyListSerialization dataWithPropertyList:self
                                                   format:NSPropertyListBinaryFormat_v1_0
                                                  options:0
                                                    error:NULL]
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
		return [self copy] ;
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