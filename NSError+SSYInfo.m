#import "NSError+SSYInfo.h"
#import "NSError+InfoAccess.h"

NSString* const SSYMethodNameErrorKey = @"Method Name" ;
NSString* const SSYLocalizedTitleErrorKey = @"Localized Title" ;
NSString* const SSYUnderlyingExceptionErrorKey = @"Underlying Exception" ;
NSString* const SSYTimestampErrorKey = @"Timestamp" ;
NSString* const SSYHttpStatusCodeErrorKey = @"HTTP Status Code" ;
NSString* const SSYDontShowSupportEmailButtonErrorKey = @"dontShowSupportEmailButton" ;
NSString* const SSYIsOnlyInformationalErrorKey = @"isOnlyInformational" ;
NSString* const SSYIsLoggedErrorKey = @"isLogged" ;
NSString* const SSYDidRecoverInvocationErrorKey = @"didRecoverInvocation" ;

@implementation NSError (SSYInfo)

- (NSError*)errorByAddingDidRecoverInvocation:(NSInvocation*)didRecoverInvocation {
	return [self errorByAddingUserInfoObject:didRecoverInvocation
									  forKey:SSYDidRecoverInvocationErrorKey] ;
}

- (NSInvocation*)didRecoverInvocation {
	return [[self userInfo] objectForKey:SSYDidRecoverInvocationErrorKey] ;
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

@end
