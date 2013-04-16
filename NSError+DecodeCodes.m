#import "NSError+DecodeCodes.h"
#import "NSError+MyDomain.h"

@implementation NSError (DecodeCodes)

- (NSArray*)codesArray {
	NSMutableArray* codes = [NSMutableArray array] ;
	NSError* error = self ;
	while (error) {
		[codes addObject:[NSNumber numberWithInteger:[error code]]] ;
		error = [[error userInfo] objectForKey:NSUnderlyingErrorKey] ;
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
        error = [[error userInfo] objectForKey:NSUnderlyingErrorKey] ;
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

@end
