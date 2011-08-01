#import "NSAppleScript+ThreadSafe.h"
#import "NSInvocation+Quick.h"
#import "NSError+SSYAdds.h"

@implementation NSAppleScript (ThreadSafe)

+ (BOOL)unsafeExecuteSource:(NSString*)source
					error_p:(NSError**)error_p {
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source] ;
	NSDictionary* errorDictionary = nil ;
	NSAppleEventDescriptor* result = [script executeAndReturnError:&errorDictionary] ;
	if (errorDictionary && error_p) {
		*error_p = SSYMakeError(150494, @"AppleScript execution failed") ;
		*error_p = [*error_p errorByAddingUserInfoObject:source
												  forKey:@"Source"] ;
		*error_p = [*error_p errorByAddingUserInfoObject:errorDictionary
												  forKey:@"Script Error Dictionary"] ;
	}
	[script release] ;
	
	return (result != nil) ; 
}

+ (BOOL)threadSafelyExecuteSource:(NSString*)source
						  error_p:(NSError**)error_p {
	NSInvocation* invocation = [NSInvocation invocationWithTarget:self
														 selector:@selector(unsafeExecuteSource:error_p:)
												  retainArguments:YES
												argumentAddresses:&source, &error_p] ;
	[invocation invokeOnMainThreadWaitUntilDone:YES] ;
	NSUInteger length = [[invocation methodSignature] methodReturnLength] ;
	void* buffer = (void*)malloc(length) ;
	[invocation getReturnValue:buffer] ;
	BOOL ok = *(BOOL*)buffer ;
	free(buffer) ;
	
	return ok ;
}

@end