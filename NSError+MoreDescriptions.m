#import "NSError+MoreDescriptions.h"
#import "NSDate+NiceFormats.h"
#import "NSString+Truncate.h"
#import "NSObject+DeepCopy.h"
#import "NSString+LocalizeSSY.h"

NSString* const SSYDidTruncateErrorDescriptionTrailer = @"\n\n*** Note: That error description was truncated! ***" ;

@implementation NSError (MoreDescriptions)

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
		userInfoMaxValueLength = 35000 ;
		userInfoMaxTotalLength = 50000 ;
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
			underlyingError = [[underlyingError userInfo] objectForKey:NSUnderlyingErrorKey] ;
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
		error = [[error userInfo] objectForKey:NSUnderlyingErrorKey] ;
	}
    
	return code ;
}

@end
