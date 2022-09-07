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

- (NSError*)encodingFriendlyError {
    NSMutableDictionary* sanitizedUserInfo = [self.userInfo mutableCopy];
    NSMutableSet* removedKeys = [NSMutableSet new];
    if ([sanitizedUserInfo objectForKey:SSYDidRecoverInvocationErrorKey]) {
        [sanitizedUserInfo removeObjectForKey:SSYDidRecoverInvocationErrorKey];
        [removedKeys addObject:SSYDidRecoverInvocationErrorKey];
    }
    if ([sanitizedUserInfo objectForKey:NSRecoveryAttempterErrorKey]) {
        [sanitizedUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
        [removedKeys addObject:NSRecoveryAttempterErrorKey];
    }
    if ([removedKeys count] > 0) {
        [sanitizedUserInfo setObject:removedKeys
                              forKey:@"Removed unencodeable keys"];
    }
    
    NSDictionary* newUserInfo = [sanitizedUserInfo copy];
    
    NSError* answer = [NSError errorWithDomain:self.domain
                                          code:self.code
                                      userInfo:newUserInfo];
    
    [sanitizedUserInfo release];
    [removedKeys release];
    [newUserInfo release];
    
    return answer;
}

@end
