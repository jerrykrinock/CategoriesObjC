#import "NSObject+DeepCopy.h"
#import "NSObject+MoreDescriptions.h"

SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskCopy = 1 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskMutable = 2 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskEncodeable = 4 ;
SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskSerializable = 8 ;

@implementation NSObject (DeepCopy)

/* Just because an object conforms to NSCoding or responds to
 encodeWithCoder: doesn't mean that it's encodeable.  Example: An
 NSError with nonencodeable objects in its userInfo dictionary.

 The only way to find out if it's *really* encodeable is to try encoding
 it and see if an exception is raised, and also test the encoded
 archive and see if it decodes to something which is not nil.  This is what
 we did until macOS 10.10.  Then things started to not work so well…

 In macOS 10.10, we could no longer catch the exception which was raised.

 In macOS 10.12.5, +[NSKeyedArchiver archivedDataWithRootObject:] began
 crashing instead of raising an exception when passed an NSError that
 contained a NSMergeConflict in its userInfo.

 In macOS 10.14.4 beta 2, the same started happening when such userInfo
 contained a custom unencodeable value (a Stark object).

 I was hoping that using the newer archive method
 archivedDataWithRootObject:requiringSecureCoding:error: instead of
 archivedDataWithRootObject: would help, but it did not. :(

 So, I am instead left with the following ad hoc implementation which fixes
 all of the crashes in my apps by recursively searching any enclosed
 collections and userInfo dictionaries for the offending types.  I'll probably
 be back here again in the future :(
 */
- (BOOL)isDeeplyEncodeable {
    if (![self respondsToSelector:@selector(encodeWithCoder:)]) {
        return NO;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        for (NSObject* value in [(NSDictionary*)self allValues]) {
            if (![value isDeeplyEncodeable]) {
                return NO;
            }
        }
    } else if ([self conformsToProtocol:@protocol(NSFastEnumeration)]) {
        for (NSObject* object in (NSArray*)self) {
            if (![object isDeeplyEncodeable]) {
                return NO;
            }
        }
    } else if ([self isKindOfClass:[NSMergeConflict class]]) {
        return NO;
    } else if ([self respondsToSelector:@selector(userInfo)]) {
        if (![[(NSError*)self userInfo] isDeeplyEncodeable]) {
            return NO;
        }
    }

    // It *may* be encodeable.
    @try {
        NSData* archive = nil;
        if (@available(macOS 10.13, *)) {
            // macOS 10.13 or later
            NSError* error = nil;
            archive = [NSKeyedArchiver archivedDataWithRootObject:self
                                            requiringSecureCoding:NO
                                                            error:&error];
            if (error) {
                archive = nil;
            }
        } else {
            archive = [NSKeyedArchiver archivedDataWithRootObject:self] ;
        }

        if (!archive) {
            return NO;
        }

        /* The following condition was added when testing in
         macOS 10.12 Sierra Beta 6.  This object was a Client
         object.  Exception occurred below, when sending
         -unarchiveObjectWithData: to it, due to
         "-[Client initWithCoder:]: unrecognized selector".
         Indeed, I checked and found that Client respnds to
         -encodeWithCoder: but not -initWithCoder. */
        id unarchivedSelf = [NSKeyedUnarchiver unarchiveObjectWithData:archive] ;
        if (!unarchivedSelf) {
            /* This can occur in macOS 10.10 and later. */
            return NO;
        }
        else {
            /* I've never seen this happen, but let's check one
             more thing, in case Apple does something else weird
             in some future macOS.  Actually, this about covers
             all possibilities, because if the unarchived object
             is equal to the pre-archived object, it is good by
             definition.  The only thing we haven't covered is if
             Apple decides to make -[[NSKeyedArchiver
             archivedDataWithRootObject:] crash when passed an
             unencodeable object. */
            if (![self isEqual:unarchivedSelf]) {
                return NO;
            }
        }
    } @catch (id anyException) {
        /* This can occur in macOS 10.9 and earlier.  Unfortunately,
         Cocoa will log an *** exception saying that something bad
         happened.  So we try to nullify that by logging a friendly
         follow-on message to explain that this is nothing to worry
         about. */
        NSLog(@"Howdy.  The above exception, and the one which follows, "
              @"are expected behavior in testing for encodeability: %@.  "
              @"It's not a bug.  Just ignore it.",
              [self class]) ;
        return NO;
    }

    return YES;
}

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
- (id)copyLeafStyle:(SSYDeepCopyStyleBitmask)style {
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
			![self isDeeplyEncodeable]
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

- (id)mutableCopyDeepStyle:(SSYDeepCopyStyleBitmask)style {
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
