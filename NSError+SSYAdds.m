#import "NSError+SSYAdds.h"
#import "NSString+Truncate.h"
#import "NSObject+DeepCopy.h"
#import "NSString+LocalizeSSY.h"
#import "NSDictionary+SimpleMutations.h"
#import "NSObject+MoreDescriptions.h"
#import "NSString+MorePaths.h"
#import "SSYDebug.h"
#import "NSDate+NiceFormats.h"

NSString* const SSYMethodNameErrorKey = @"Method Name" ;
NSString* const SSYLocalizedTitleErrorKey = @"Localized Title" ;
NSString* const SSYUnderlyingExceptionErrorKey = @"Underlying Exception" ;
NSString* const SSYTimestampErrorKey = @"Timestamp" ;
NSString* const SSYRecoveryAttempterUrlErrorKey = @"RecoveryAttempterUrl" ;
NSString* const SSYRetryDateErrorKey = @"RetryDate" ;
NSString* const SSYRecoveryAttempterIsAppDelegateErrorKey = @"RecoveryAttempterIsAppDelegate" ;
NSString* const SSYHttpStatusCodeErrorKey = @"HTTP Status Code" ;
NSString* const SSYDontShowSupportEmailButtonErrorKey = @"dontShowSupportEmailButton" ;
NSString* const SSYIsOnlyInformationalErrorKey = @"isOnlyInformational" ;
NSString* const SSYIsLoggedErrorKey = @"isLogged" ;
NSString* const SSYDidRecoverInvocationErrorKey = @"didRecoverInvocation" ;


NSString* const SSYDidTruncateErrorDescriptionTrailer = @"\n\n*** Note: That error description was truncated! ***" ;

@implementation NSError (SSYAdds) 

+ (NSString*)myDomain {
	NSString* domain = [[NSBundle mainBundle] bundleIdentifier] ;
	// Background/daemon/helper/tools will usually not have a bundle...
	if (!domain) {
		NSString* path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0] ;
		domain = [path lastPathComponent] ;
	}
	if (!domain) {
		domain = @"UnknownErrorDomain" ;
	}
	
	return domain ;
}

+ (NSError*)errorWithLocalizedDescription:(NSString*)localizedDescription
									 code:(NSInteger)code
						   prettyFunction:(const char*)prettyFunction {
	NSDictionary* userInfo = nil ;
	if (localizedDescription) {
		NSString* const CFBundleVersionKey = @"CFBundleVersion" ;
		userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					localizedDescription, NSLocalizedDescriptionKey,
					[[NSBundle mainBundle] objectForInfoDictionaryKey:CFBundleVersionKey], CFBundleVersionKey,
					// The following gets added in -[SSYAlert support:].  It would be nice to do it here instead.
					// But then I'd have to #import SSYSystemDescriber into any project using this file.
					//[SSYSystemDescriber softwareVersionAndArchitecture], @"System Description",
					nil] ;
	}

	NSError* error = [NSError errorWithDomain:[self myDomain]
										 code:code
									 userInfo:userInfo] ;

	error = [error errorByAddingPrettyFunction:prettyFunction] ;
	error = [error errorByAddingTimestampNow] ;
	
	return error ;
}


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

- (NSError*)errorByAddingRecoveryAttempter:(id)recoveryAttempter {
	return [self errorByAddingUserInfoObject:recoveryAttempter
									  forKey:NSRecoveryAttempterErrorKey] ;
}

- (NSError*)errorByAddingRecoveryAttempterUrl:(NSURL*)url {
	return [self errorByAddingUserInfoObject:url
									  forKey:SSYRecoveryAttempterUrlErrorKey] ;
}

- (NSError*)errorByAddingRecoveryAttempterIsAppDelegate {
	return [self errorByAddingUserInfoObject:[NSNumber numberWithBool:YES]
									  forKey:SSYRecoveryAttempterIsAppDelegateErrorKey] ;
}

- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions {
	return [self errorByAddingUserInfoObject:recoveryOptions
									  forKey:NSLocalizedRecoveryOptionsErrorKey] ;
}

- (NSError*)errorByAddingDidRecoverInvocation:(NSInvocation*)didRecoverInvocation {
	return [self errorByAddingUserInfoObject:didRecoverInvocation
									  forKey:SSYDidRecoverInvocationErrorKey] ;
}

- (NSInvocation*)didRecoverInvocation {
	return [[self userInfo] objectForKey:SSYDidRecoverInvocationErrorKey] ;
}

- (NSError*)errorByAddingHelpAnchor:(NSString*)helpAnchor {
	return [self errorByAddingUserInfoObject:helpAnchor
									  forKey:NSHelpAnchorErrorKey] ;
}

- (NSError*)underlyingError {
	return [[self userInfo] objectForKey:NSUnderlyingErrorKey] ;
}

- (NSError*)bottomError {
	NSError* bottomError ;
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
	[exceptionInfo release] ;
	
	return [self errorByAddingUserInfoObject:info
									  forKey:SSYUnderlyingExceptionErrorKey] ;
}

- (NSError*)errorByAddingLocalizedTitle:(NSString*)title {
	return [self errorByAddingUserInfoObject:title
									  forKey:SSYLocalizedTitleErrorKey] ;
}

- (NSError*)errorByRemovingRecoveryAttempter {
	NSMutableDictionary* userInfo = [[self userInfo] mutableCopy] ;
	[userInfo removeObjectForKey:NSRecoveryAttempterErrorKey] ;
	
	NSError* error = [NSError errorWithDomain:[self domain]
										 code:[self code]
									 userInfo:userInfo] ;
	[userInfo release] ;
	
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

- (NSError*)errorByAddingDontShowSupportEmailButton {
	return [self errorByAddingUserInfoObject:[NSNumber numberWithBool:YES]
									  forKey:SSYDontShowSupportEmailButtonErrorKey] ;
}

- (BOOL)shouldShowSupportEmailButton {
	return (![[self userInfo] objectForKey:SSYDontShowSupportEmailButtonErrorKey]) ;
}

- (NSError*)errorByAddingIsOnlyInformational {
	return [self errorByAddingUserInfoObject:[NSNumber numberWithBool:YES]
															forKey:SSYIsOnlyInformationalErrorKey] ;
}

- (NSError*)maybeAddMountVolumeRecoverySuggestion {
	NSError* error = self ;
	NSString* path = [[self userInfo] objectForKey:@"Path"] ;
	NSString* volumePath = [path volumePath] ;
	if (volumePath) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:volumePath]) {
			NSString* msg = [NSString stringWithFormat:
							 @"Mount the volume '%@'",
							 [[volumePath pathComponents] objectAtIndex:2]] ;
			error = [self errorByAddingLocalizedRecoverySuggestion:msg] ;
		}
	}
	
	return error ;
}

- (NSError*)errorByAddingBacktrace {
	return [self errorByAddingUserInfoObject:SSYDebugBacktrace()
									  forKey:@"Backtrace"] ;
}

- (BOOL)isOnlyInformational {
	return ([[self userInfo] objectForKey:SSYIsOnlyInformationalErrorKey] != nil) ;
}


- (NSError*)errorByAddingIsLogged {
	return [self errorByAddingUserInfoObject:[NSNumber numberWithBool:YES]
									  forKey:SSYIsLoggedErrorKey] ;
}

- (BOOL)isLogged {
	return ([[[self userInfo] objectForKey:SSYIsLoggedErrorKey] boolValue]) ;
}

- (NSString*)longDescriptionWithIndentationLevel:(NSInteger)indentationLevel
								truncateForEmail:(BOOL)truncateForEmail {
	// Unfortunately, if you carefully read the documentation for NSError you'll see
	// that the NSLocalizedDescriptionKey may or may not be in the userInfo
	// dictionary.  So, in order to present a consistent email content, we first
	// put it into the userInfo dictionary if it is not in there.
	NSDictionary* userInfo = [self userInfo] ;
	if (![userInfo objectForKey:NSLocalizedDescriptionKey]) {
		NSString* localizedDescription = [self localizedDescription] ;
		if (localizedDescription) {
			NSMutableDictionary* userInfoMute = [NSMutableDictionary dictionaryWithDictionary:userInfo] ;
			[userInfoMute setObject:localizedDescription
							 forKey:NSLocalizedDescriptionKey] ;
			userInfo = userInfoMute ;
		}
	}
	
	NSMutableString* indentation = [NSMutableString string] ;
	NSInteger ii ;
	for (ii=0; ii<indentationLevel; ii++) {
		[indentation appendString:@"   "] ;
	}

	// Set truncation limits
	NSInteger userInfoMaxKeyLength ;
	NSInteger userInfoMaxValueLength;
	NSInteger userInfoMaxTotalLength;
	if (truncateForEmail) {
		userInfoMaxKeyLength = 256 ;
		userInfoMaxValueLength = 16384 ;
		userInfoMaxTotalLength = 32768;
	}
	else {
		userInfoMaxKeyLength = 65536 ;
		userInfoMaxValueLength = 524288 ;
		userInfoMaxTotalLength = 2097152 ;  // 2 MB
	}
	BOOL didTruncate = NO ;
	
	// The following is to make sure that if something really went haywire and caused
	// the NSError's userInfo dictionary to become very large, we truncate each key and
	// values, and the aggregate description, to a readable length so that the user
	// will not be afraid to send it and the support engineer will not be afraid to
	// read it.
	NSMutableString* truncatedUserInfo = [NSMutableString string] ;
	// For readability, sort keys so that the underyling error, if any, is last.
	NSMutableArray* keys = [[userInfo allKeys] mutableCopy] ;
	if ([keys indexOfObject:NSUnderlyingErrorKey] != NSNotFound) {
		[keys removeObject:NSUnderlyingErrorKey] ;
		[keys addObject:NSUnderlyingErrorKey] ;
	}
	NSEnumerator* e = [keys objectEnumerator] ;
	id key ;
	id value ;
	while ((key = [e nextObject]) != nil) {
		if ([truncatedUserInfo length] > userInfoMaxTotalLength) {
			didTruncate = YES ;
			break ;
		}
		
		value = [userInfo objectForKey:key] ;
		NSString* keyDescription = [key description] ;
		NSString* valueDescription = nil ;
		if ([value respondsToSelector:@selector(longDescriptionWithIndentationLevel:truncateForEmail:)]) {
			// value must be an underlying error
			NSInteger nextIndentationLevel = (indentationLevel + 1) ;
			valueDescription = [value longDescriptionWithIndentationLevel:nextIndentationLevel
														 truncateForEmail:truncateForEmail] ;
		}
		if (!valueDescription) {
			// value is a value
			if ([value respondsToSelector:@selector(geekDateTimeString)]) {
				// value is a date
				valueDescription = [value geekDateTimeString] ;
			}
			else {
				valueDescription = [value longDescription] ;
			}
		}
		NSString* truncatedKey = [keyDescription stringByTruncatingMiddleToLength:userInfoMaxKeyLength
																	   wholeWords:NO] ;
		if ([truncatedKey length] < [keyDescription length]) {
			didTruncate = YES ;
		}
		NSString* truncatedValue = [valueDescription stringByTruncatingMiddleToLength:userInfoMaxValueLength
																		   wholeWords:NO] ;
		if ([truncatedValue length] < [valueDescription length]) {
			didTruncate = YES ;
		}
		[truncatedUserInfo appendFormat:
		 @"%@   **Key: %@\n"
		 @"%@   Value: %@\n",
		 indentation,
		 truncatedKey,
		 indentation,
		 truncatedValue] ;
	}
	[keys release] ;
	
	NSString* maybeTruncateTrailer = didTruncate ? SSYDidTruncateErrorDescriptionTrailer : @"" ;

	return [NSString stringWithFormat:
			@"%@NSError %p\n"
			@"%@***     code: %ld\n"
			@"%@***   domain: %@\n"
			@"%@*** userInfo:\n%@%@",
			indentation,
			self,
			indentation,
			(long)[self code],
			indentation,
			[self domain],
			indentation,
			truncatedUserInfo,
			maybeTruncateTrailer] ;
}

- (void)appendIfExistsUserInfoValueForKey:(NSString*)key
								withLabel:(NSString*)label
							toDescription:(NSMutableString*)string {
	id value = [[self userInfo] objectForKey:key] ;
	if (value) {
		if ([value respondsToSelector:@selector(geekDateTimeString)]) {
			// It's a date
			value = [value geekDateTimeString] ;
		}
		[string appendFormat:@"\n\n%@\n%@", label, value] ;
	}
}

- (NSString*)descriptionForDialog {
	NSMutableString* dialogDescription = [[self localizedDescription] mutableCopy] ;
	
	[self appendIfExistsUserInfoValueForKey:NSLocalizedFailureReasonErrorKey
								  withLabel:[NSString localize:@"errorReasonLabel"]
							  toDescription:dialogDescription] ;
	
	[self appendIfExistsUserInfoValueForKey:NSLocalizedRecoverySuggestionErrorKey
								  withLabel:[NSString localize:@"errorRecoveryLabel"]
							  toDescription:dialogDescription] ;
	
	if ([NSError respondsToSelector:@selector(additionalKeysInDescriptionForDialog)]) {
		NSArray* additionalKeys = [NSError performSelector:@selector(additionalKeysInDescriptionForDialog)] ;
		NSEnumerator* e = [additionalKeys objectEnumerator] ;
		NSString* key ;
		while ((key = [e nextObject])) {
			[self appendIfExistsUserInfoValueForKey:key
										  withLabel:[NSString localizeWeakly:key]
									  toDescription:dialogDescription] ;
		}
	}			
	
	NSString* answer = [dialogDescription copy] ;
	[dialogDescription release] ;
	return [answer autorelease] ;
}

- (NSString*)localizedTitle {
	NSString* title = [[self userInfo] objectForKey:SSYLocalizedTitleErrorKey] ;
	
	return title ;
}

- (NSString*)localizedDeepDescription {
	BOOL moreThanOne = NO ;
	NSMutableString* deepDescription = [[NSMutableString alloc] init] ;
	NSError* underlyingError = self ;
	while (underlyingError) {
		if (moreThanOne) {
			[deepDescription appendFormat:@"\n\n\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80 %@ \xe2\x94\x80\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80\n\n",
			 [NSString localize:@"causeUnderlying"]] ;
		}
		else {
			moreThanOne = YES ;
		}
		
		NSString* nextPart ;
		if ([underlyingError respondsToSelector:@selector(descriptionForDialog)]) {
			nextPart = [underlyingError descriptionForDialog] ;
		}
		else {
			nextPart = [underlyingError description] ;
		}
		// Some defensive programming, in case a weird error returns nil for either
		// of the above...
		if (nextPart) {
			[deepDescription appendString:nextPart] ;
		}
		
		if ([underlyingError respondsToSelector:@selector(underlyingError)]) {
			underlyingError = [underlyingError underlyingError] ;
		}
		else {
			underlyingError = nil ;
		}
	}
	
	NSString* answer = [deepDescription copy] ;
	[deepDescription release] ;
	
	return [answer autorelease] ;
}

- (NSString*)longDescription {
	return [self longDescriptionWithIndentationLevel:0
									truncateForEmail:NO] ;
}

- (NSString*)mailableLongDescription {
	return [self longDescriptionWithIndentationLevel:0
									truncateForEmail:YES] ;
}

- (NSData*)keyedArchive {
	NSInteger code = [self code] ;
	NSString* domain = [self domain] ;
	NSDictionary* userInfo = [self userInfo] ;
	NSDictionary* encodeableUserInfo = [userInfo mutableCopyDeepStyle:SSYDeepCopyStyleBitmaskEncodeable] ;
	NSError* encodeableError = [NSError errorWithDomain:domain
												   code:code
											   userInfo:encodeableUserInfo] ;
	[encodeableUserInfo release] ;
	NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:encodeableError] ;
	
	return archive ;
}

- (NSInteger)mostUnderlyingErrorCode {
	NSInteger code ;
	NSError* error = self ;
	while (error) {
		code = [error code] ;
		error = [error underlyingError] ;
	}

	return code ;
}

- (NSArray*)codesArray {
	NSMutableArray* codes = [NSMutableArray array] ;
	NSError* error = self ;
	while (error) {
		[codes addObject:[NSNumber numberWithInteger:[error code]]] ;
		error = [error underlyingError] ;
	}
	return codes ;
}

- (NSSet*)allInvolvedCodesInDomain:(NSString*)domain {
	NSMutableSet* codes = [NSMutableSet set] ;
	NSError* error = self ;
	while (error) {
		NSString* errorDomain = [error domain] ;
		if (errorDomain) {
			if (!domain || [domain isEqualToString:errorDomain]) {
				[codes addObject:[NSNumber numberWithInteger:[error code]]] ;
			}
		}
		error = [error underlyingError] ;
	}
	
	NSSet* answer = [codes copy] ;
	return [answer autorelease] ;
}

- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes
						 domain:(NSString*)domain {
	for (NSNumber* targetCode in targetCodes) {
		if ([[self allInvolvedCodesInDomain:domain] member:targetCode]) {
			return YES ;
		}
	}
	
	return NO ;
}

- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes {
	return [self involvesOneOfCodesInSet:targetCodes
								  domain:nil] ;
}

- (BOOL)involvesOneOfMyCodesInSet:(NSSet*)targetCodes {
	return [self involvesOneOfCodesInSet:targetCodes
								  domain:[NSError myDomain]] ;
}


- (BOOL)involvesCode:(NSInteger)code
			  domain:(NSString*)domain {
	return [self involvesOneOfCodesInSet:[NSSet setWithObject:[NSNumber numberWithInteger:code]]
								  domain:domain] ;
}

- (BOOL)involvesCode:(NSInteger)code {
	return [self involvesCode:code
					   domain:nil] ;
}

- (BOOL)involvesMyDomainAndCode:(NSInteger)code {
	return [self involvesCode:code
					   domain:[NSError myDomain]] ;
}

- (BOOL)isNotFileNotFoundError {
    if ([self code] == NSFileReadNoSuchFileError) {  // ==260
		if ([[self domain] isEqualToString:NSCocoaErrorDomain]) {
            return NO ;
        }
	}
    if ([self code] == ENOENT) {  // == 2
		if ([[self domain] isEqualToString:NSPOSIXErrorDomain]) {
            return NO ;
        }
	}
	
	return YES ;
}

- (BOOL)isUserCancelledCocoaError {
	return [self involvesCode:NSUserCancelledError
					   domain:NSCocoaErrorDomain] ;
}

- (BOOL)isRecoverable {
	return (
			(NO
			 || [self recoveryAttempter]
			 || [[self userInfo] objectForKey:SSYRecoveryAttempterUrlErrorKey]
			 || [[[self userInfo] objectForKey:SSYRecoveryAttempterIsAppDelegateErrorKey] boolValue]
			 )
			&&
			([[self localizedRecoveryOptions] count] > 0)
			) ;
}

- (NSError*)deepestRecoverableError {
	NSMutableArray* underlyingErrors = [[NSMutableArray alloc] init] ;
	[underlyingErrors addObject:self] ;
	NSError* error = self ;
	while ((error = [error underlyingError])) {
		[underlyingErrors addObject:error] ;
	}
	
	NSEnumerator* bottomUpErrors = [underlyingErrors reverseObjectEnumerator] ;
	[underlyingErrors release] ;
	
	NSError* answer = nil ;
	for (error in bottomUpErrors) {
		if ([error isRecoverable]) {
			answer = error ;
			break ;
		}
	}
	
	return answer ;
}

- (id)openRecoveryAttempterForRecoveryOption:(NSInteger)recoveryOption 
									 error_p:(NSError**)error_p {
	if (error_p) {
		*error_p = nil ;
	}

	id recoveryAttempter = [self recoveryAttempter] ;

	if (!recoveryAttempter) {
		NSURL* recoveryAttempterUrl = [[self userInfo] objectForKey:SSYRecoveryAttempterUrlErrorKey] ;
		if (recoveryAttempterUrl) {	
			
			// recoveryOption NSAlertAlternateReturn is assumed to mean "Cancel".
			if (recoveryOption == NSAlertAlternateReturn) {
				return nil ;
			}
			
			recoveryAttempter = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:recoveryAttempterUrl
																									   display:YES
																										 error:error_p] ;
		}
		else if (!recoveryAttempter) {
			if ([[[self userInfo] objectForKey:SSYRecoveryAttempterIsAppDelegateErrorKey] boolValue]) {
				recoveryAttempter = [NSApp delegate] ;
			}
		}		
	}
	
	return recoveryAttempter ;
}


@end