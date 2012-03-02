#import "NSDictionary+DeepDooDoo.h"


@implementation NSDictionary (DeepDooDoo)

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic {
#if 0
#warning Testing to see if doodoo needs to be deep
	// An initial experiment I did indicated that this method was better than -isEqualToDictionary:
	// because it would find equality of inner nested dictionaries that -isEqualToDictionary: did
	// not.  But later testing showed that -isEqualToDictionary: apparently works as desired,
	// finding equality in inner dictionaries, right out of the box.
	BOOL answer = YES ;
	if ([self count] != [otherDic count]) {
		// Dictionaries with unequal counts cannot be the same
		answer = NO ;
	}
	else {
		for (id key in self) {
			id value1 = [self objectForKey:key] ;
			id value2 = [otherDic objectForKey:key] ;
			// value1 cannot be nil, because a dictionary cannot contain
			// a nil value for any key and key is one of self's enumerated
			// keys.  But value2 could be nil if otherDic has an extra
			// key that self does not have, so that they would have cancelled
			// out and passed the count test at the beginning of this method.
			if (value2 == nil) {
				// Self has a value for key, but otherDic does not
				answer = NO ;
				break ;
			}
			
			if ([value1 isKindOfClass:[NSDictionary class]]) {
				if ([value2 isKindOfClass:[NSDictionary class]]) {
					// Found an inner dictionary.  Go deep to check equality.
					// This is the reason why this method is better than
					// -[NSDictionary isEqualToDictionary].  According to
					// its documentation, that method would use -isEqual at
					// this point.
					if (![(NSDictionary*)value1 isEqualDeepToDictionary:(NSDictionary*)value2]) {
						answer = NO ;
						break ;
					}
				}
				else {
					answer = NO ;
					break ;
				}
			}
			else {
				if (![value1 isEqual:value2]) {
					answer = NO ;
					break ;
				}
			}
		}
	}
	BOOL easyAnswer = [self isEqualToDictionary:otherDic] ;
	if (easyAnswer != answer) {
		NSLog(@"Warning 163-9341: answer=%d easyAnswer=%d\nself: %@\nother: %@", answer, easyAnswer, [self shortDescription], [otherDic shortDescription]) ;
	}
	return easyAnswer ;
#else
	return [self isEqualToDictionary:otherDic] ;
#endif
}

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic
				   ignoringKeys:(NSSet*)ignoreKeys {
	BOOL isEqual = [self isEqualDeepToDictionary:otherDic] ;
	
	if (!isEqual) {
		if ([ignoreKeys count] > 0) {
			// Maybe they'll be equal if we ignore the ignoreKeys
			NSMutableDictionary* selfFixed = [self mutableCopy] ;
			NSMutableDictionary* otherFixed = [otherDic mutableCopy] ;
			
			for (id key in ignoreKeys) {
				[selfFixed removeObjectForKey:key] ;
				[otherFixed removeObjectForKey:key] ;
			}
			isEqual = [selfFixed isEqualDeepToDictionary:otherFixed] ;
			
			[selfFixed release] ;
			[otherFixed release] ;
		}
	}
	
	return isEqual ;
}

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic
				   ignoringKeys:(NSSet*)ignoreKeys
				inSubdictionary:(NSString*)subdicKey {
	BOOL isEqual = [self isEqualDeepToDictionary:otherDic] ;

	if (!isEqual) {
		if ([ignoreKeys count] > 0) {
			// Maybe they'll be equal if we ignore the ignoreKeys in the given subdictionary
			NSMutableDictionary* selfFixed = [self mutableCopy] ;
			NSMutableDictionary* otherFixed = [otherDic mutableCopy] ;
			NSMutableDictionary* selfSubFixed = [[self objectForKey:subdicKey] mutableCopy] ;
			NSMutableDictionary* otherSubFixed = [[otherDic objectForKey:subdicKey] mutableCopy] ;
			
			for (id key in ignoreKeys) {
				[selfSubFixed removeObjectForKey:key] ;
				[otherSubFixed removeObjectForKey:key] ;
			}
			if (selfSubFixed) {
				[selfFixed setObject:selfSubFixed
							  forKey:subdicKey] ;
			}
			else {
				// We do not need to -removeObjectForKey:subdicKey here, because the only way that
				// the value for key selfSubFixed could be nil is if self did not have an object
				// for key subdicKey, and that means that selfFixed already does not have an
				// object for key subdicKey.
			}
			if (otherSubFixed) {
				[otherFixed setObject:otherSubFixed
							   forKey:subdicKey] ;
			}
			else {
				// We do not need to -removeObjectForKey:subdicKey here, because the only way that
				// the value for key otherSubFixed could be nil is if otherDic did not have an object
				// for key subdicKey, and that means that otherFixed already does not have an
				// object for key subdicKey.
			}
			isEqual = [selfFixed isEqualDeepToDictionary:otherFixed] ;
			
			[selfFixed release] ;
			[otherFixed release] ;
			[selfSubFixed release] ;
			[otherSubFixed release] ;
		}
	}
	
	return isEqual ;
}

@end

#if COMPILING_TEST_CODE_FOR_NSDICTIONARY_DEEPDOODOO
#warning Compiling Test Code for NSDictionary (DeepDooDoo)

@implementation NSDictionary (DeepDooDooTest)

- (void)testEqualToDictionary:(NSDictionary*)otherDic
				 ignoringKeys:(NSSet*)ignoreKeys 
			  inSubdictionary:(NSString*)subdicKey {
	BOOL r1 = [self isEqualToDictionary:otherDic] ;
	BOOL r2 = [self isEqualDeepToDictionary:otherDic] ;
	BOOL r3 = [self isEqualDeepToDictionary:otherDic
							   ignoringKeys:ignoreKeys] ;
	BOOL r4 = [self isEqualDeepToDictionary:otherDic
							   ignoringKeys:ignoreKeys
							inSubdictionary:subdicKey] ;
	NSLog(
		  @"*********************************************\n"
		  @"Comparing self: %@\nTo: %@\n"
		  @"Results:  r1=%d  r2=%d  r3=%d  r4=%d", self, otherDic, r1, r2, r3, r4
		  ) ;
}

@end

#endif