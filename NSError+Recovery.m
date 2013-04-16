#import "NSError+Recovery.h"

NSString* const SSYRecoveryAttempterUrlErrorKey = @"RecoveryAttempterUrl" ;
NSString* const SSYRetryDateErrorKey = @"RetryDate" ;
NSString* const SSYRecoveryAttempterIsAppDelegateErrorKey = @"RecoveryAttempterIsAppDelegate" ;

@implementation NSError (Recovery)

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
	while ((error = [[error userInfo] objectForKey:NSUnderlyingErrorKey])) {
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
