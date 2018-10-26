#import "NSError+InfoAccess.h"
#import "NSDictionary+SimpleMutations.h"

NSString* const SSYMethodNameErrorKey = @"Method Name" ;
NSString* const SSYLocalizedTitleErrorKey = @"Localized Title" ;
NSString* const SSYUnderlyingExceptionErrorKey = @"Underlying Exception" ;
NSString* const SSYTimestampErrorKey = @"Timestamp" ;
NSString* const SSYHttpStatusCodeErrorKey = @"HTTP Status Code" ;

@implementation NSError (InfoAccess)

- (NSString*)uniqueKeyForBaseKey:(NSString*)baseKey
				  sequenceNumber:(NSInteger)sequenceNumber {
	NSString* uniqueKey ;
	if (sequenceNumber == 0) {
		uniqueKey = baseKey ;
	}
	else {
		uniqueKey = [NSString stringWithFormat:
						@"%@-%02ld",
						[baseKey description],
						(long)sequenceNumber] ;
	}
	
	return uniqueKey ;
}


- (NSError*)errorByAddingUserInfoObject:(id)object
								 forKey:(NSString*)baseKey {
	NSError* answer ;
	if (object != nil) {
		NSDictionary* userInfo = [self userInfo] ;
		if (userInfo) {
			// Find the next, unused sequence number
			// Will be 0 if there are no such keys yet with this base
			// Will be 1 if there is 1 other such key with this base
			// etc.
			NSInteger nextSequenceNumber = 0 ;
			while ([userInfo objectForKey:[self uniqueKeyForBaseKey:baseKey
													 sequenceNumber:nextSequenceNumber]]) {
				nextSequenceNumber++ ;
			}
			
			// Increment the sequence number of each existing key, if any
			NSInteger i ;
			for (i=nextSequenceNumber; i>0; i--) {
				NSString* oldKey = [self uniqueKeyForBaseKey:baseKey
											  sequenceNumber:(i-1)] ;
				NSString* newKey = [self uniqueKeyForBaseKey:baseKey
											  sequenceNumber:i] ;
				userInfo = [userInfo dictionaryBySettingValue:[userInfo objectForKey:oldKey]
													   forKey:newKey] ;
			}
			
			// Set the newest object as the base key
			userInfo = [userInfo dictionaryBySettingValue:object
												   forKey:baseKey] ;
		}
		else {
			userInfo = [NSDictionary dictionaryWithObject:object
												   forKey:baseKey] ;
		}
		
		answer = [NSError errorWithDomain:[self domain]
									 code:[self code]
								 userInfo:userInfo] ;		
	}
	else {
		answer = self ;
	}

	return answer ;
}

- (NSError*)errorByAddingUserInfoSet:(NSSet*)set
                              forKey:(NSString*)key
                          truncateTo:(NSInteger)truncateTo {
    if ([set count] == 0) {
        return self ;
    }
    
    if (truncateTo > 0) {
        if (truncateTo < [set count]) {
            NSMutableSet* mutaset = [[NSMutableSet alloc] init] ;
            NSInteger i = 0 ;
            for (id object in set) {
                if (i < truncateTo) {
                    [mutaset addObject:object] ;
                    i++ ;
                }
                else {
                    break ;
                }
            }
            
            set = [mutaset copy] ;

#if !__has_feature(objc_arc)
            [set autorelease] ;
            [mutaset release] ;
#endif

            key = [key stringByAppendingFormat:
                   @" (only first %ld)",
                   (long)truncateTo] ;
        }
    }
    
    return [self errorByAddingUserInfoObject:set
                                      forKey:key] ;
}

- (NSError*)errorByOverwritingUserInfoObject:(id)object
									  forKey:(NSString*)key {
	NSError* answer ;
	if (object != nil) {
		NSDictionary* userInfo = [self userInfo] ;
		if (userInfo) {
			userInfo = [userInfo dictionaryBySettingValue:object
												   forKey:key] ;
		}
		else {
			userInfo = [NSDictionary dictionaryWithObject:object
												   forKey:key] ;
		}
		
		answer = [NSError errorWithDomain:[self domain]
									 code:[self code]
								 userInfo:userInfo] ;		
	}
	else {
		answer = self ;
	}
	
	return answer ;
}

- (NSError*)errorByAddingLocalizedDescription:(NSString*)newText {
	return [self errorByAddingUserInfoObject:newText
									  forKey:NSLocalizedDescriptionKey] ;
}

- (NSError*)errorByAddingLocalizedFailureReason:(NSString*)failureReason {
	NSError* answer ;
	if (failureReason != nil) {
		NSDictionary* userInfo = [self userInfo] ;
		if (userInfo) {
			userInfo = [userInfo dictionaryBySettingValue:failureReason
												   forKey:NSLocalizedFailureReasonErrorKey] ;
		}
		else {
			userInfo = [NSDictionary dictionaryWithObject:failureReason
												   forKey:NSLocalizedFailureReasonErrorKey] ;
		}
		
		answer = [NSError errorWithDomain:[self domain]
									 code:[self code]
								 userInfo:userInfo] ;		
	}
	else {
		answer = self ;
	}
	
	return answer ;
}

- (NSError*)errorByAppendingText:(NSString*)moreText
                   toValueForKey:(NSString*)key {
    NSError* answer ;
	if (moreText) {
		NSString* text = [[self userInfo] objectForKey:key] ;
		if (text) {
			text = [NSString stringWithFormat:
                    @"%@  %@",
                    text,
                    moreText] ;
		}
        else {
            text = moreText ;
        }
        
		answer = [self errorByOverwritingUserInfoObject:text
                                                 forKey:key] ;
	}
	else {
		answer = self ;
	}
	
	return answer ;
}

- (NSError*)errorByAppendingLocalizedDescription:(NSString*)moreText {
    return [self errorByAppendingText:moreText
                        toValueForKey:NSLocalizedDescriptionKey] ;
}

- (NSError*)errorByAppendingLocalizedFailureReason:(NSString*)moreText {
    return [self errorByAppendingText:moreText
                        toValueForKey:NSLocalizedFailureReasonErrorKey] ;
}

- (NSError*)errorByAppendingLocalizedRecoverySuggestion:(NSString*)moreText {
    return [self errorByAppendingText:moreText
                        toValueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
}

- (NSError*)errorByAddingPrettyFunction:(const char*)prettyFunction {
	NSError* error = nil  ;
	if (prettyFunction != NULL) {
		error = [self errorByAddingUserInfoObject:[NSString stringWithCString:prettyFunction
																	 encoding:NSUTF8StringEncoding]
										   forKey:SSYMethodNameErrorKey] ;
	}
	else {
		error = self ; 
	}
	
	return error ;
}

- (NSError*)errorByAddingLocalizedRecoverySuggestion:(NSString*)newText {
	return [self errorByAddingUserInfoObject:newText
									  forKey:NSLocalizedRecoverySuggestionErrorKey] ;
}

- (NSError*)errorByAddingInfoToExplainMissingAppResource {
    NSError* error = [self errorByAppendingLocalizedFailureReason:@"This can happen if this application was moved while it was running, or if its package is incomplete."] ;
    error = [error errorByAppendingLocalizedRecoverySuggestion:@"If you've moved this application, relaunch it.  Otherwise, try reinstalling it."] ;
    return error ;
}

- (NSError*)errorByAddingRecoveryAttempter:(id)recoveryAttempter {
	return [self errorByAddingUserInfoObject:recoveryAttempter
									  forKey:NSRecoveryAttempterErrorKey] ;
}

- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions {
	return [self errorByAddingUserInfoObject:recoveryOptions
									  forKey:NSLocalizedRecoveryOptionsErrorKey] ;
}

- (NSError*)errorByAddingHelpAddress:(NSString*)helpAddress {
	return [self errorByAddingUserInfoObject:helpAddress
									  forKey:NSHelpAnchorErrorKey] ;
}

- (NSError*)underlyingError {
	return [[self userInfo] objectForKey:NSUnderlyingErrorKey] ;
}

- (NSError*)bottomError {
	NSError* bottomError = nil ;
	NSError* nextError = self ;
	while (nextError) {
		bottomError = nextError ;
		nextError = [nextError underlyingError] ;
	}
	
	return bottomError ;
}

- (NSError*)errorByAddingUnderlyingError:(NSError*)underlyingError {
	return [[self bottomError] errorByAddingUserInfoObject:underlyingError
															forKey:NSUnderlyingErrorKey] ;
}

- (NSError*)errorByAddingUnderlyingException:(NSException*)exception {
	NSMutableDictionary* exceptionInfo = [[NSMutableDictionary alloc] init] ;
	id value ;
	
	value = [exception name] ;
	if (value) {
		[exceptionInfo setObject:value
						  forKey:@"Name"] ;
	}
	
	value = [exception reason] ;
	if (value) {
		[exceptionInfo setObject:value
						  forKey:@"Reason"] ;
	}
	
	value = [exception userInfo] ;
	if (value) {
		[exceptionInfo setObject:value
						  forKey:@"User Info"] ;
	}
	
	NSDictionary* info = [NSDictionary dictionaryWithDictionary:exceptionInfo] ;
#if !__has_feature(objc_arc)
	[exceptionInfo release] ;
#endif
	return [self errorByAddingUserInfoObject:info
									  forKey:SSYUnderlyingExceptionErrorKey] ;
}

- (NSError*)errorByAddingLocalizedTitle:(NSString*)title {
	return [self errorByAddingUserInfoObject:title
									  forKey:SSYLocalizedTitleErrorKey] ;
}

- (NSString*)localizedTitle {
	NSString* title = [[self userInfo] objectForKey:SSYLocalizedTitleErrorKey] ;
	
	return title ;
}

- (NSError*)errorByRemovingRecoveryAttempter {
	NSMutableDictionary* userInfo = [[self userInfo] mutableCopy] ;
	[userInfo removeObjectForKey:NSRecoveryAttempterErrorKey] ;
	
	NSError* error = [NSError errorWithDomain:[self domain]
										 code:[self code]
									 userInfo:userInfo] ;
#if !__has_feature(objc_arc)
	[userInfo release] ;
#endif
	return error ;
}

- (NSError*)errorByAddingTimestamp:(NSDate*)date {
	return [self errorByAddingUserInfoObject:date
									  forKey:SSYTimestampErrorKey] ;
}

- (NSError*)errorByAddingTimestampNow {
	return [self errorByAddingTimestamp:[NSDate date]] ;
}

- (NSDate*)timestamp {
	return [[self userInfo] objectForKey:SSYTimestampErrorKey] ;
}


@end
