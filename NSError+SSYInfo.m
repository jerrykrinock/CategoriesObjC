#import "NSError+SSYInfo.h"
#import "NSError+InfoAccess.h"
#import "SSYDebug.h"

NSString* const SSYIsOnlyInformationalErrorKey = @"isOnlyInformational" ;
NSString* const SSYIsLoggedErrorKey = @"isLogged" ;
NSString* const SSYDidRecoverInvocationErrorKey = @"didRecoverInvocation" ;
NSString* const SSYDontShowSupportEmailButtonErrorKey = @"dontShowSupportEmailButton" ;

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

- (NSError*)errorByChangingCodeTo:(NSInteger)code {
    return [NSError errorWithDomain:[self domain]
                               code:code
                           userInfo:[self userInfo]] ;
}

@end
