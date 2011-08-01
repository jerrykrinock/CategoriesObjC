#import "NSInvocation+Nesting.h"
#import "NSInvocation+Quick.h"

@implementation NSInvocation (Nesting)

+ (void)invokeInvocations:(NSArray*)invocations {
	for (NSInvocation* invocation in invocations) {
		[invocation invoke] ;
	}
}


+ (NSInvocation*)invocationWithInvocations:(NSArray*)invocations {
	NSInvocation* invocation = [NSInvocation invocationWithTarget:self
														 selector:@selector(invokeInvocations:)
												  retainArguments:YES
												argumentAddresses:&invocations] ;
	return invocation ;
}

- (BOOL)hasEggs {
	if (!([self selector] == @selector(invokeInvocations:))) {
		return NO ;
	}
	if (!([self target] == [NSInvocation class])) {
		return NO ;
	}
	
	return YES ;
}

@end