#import "NSError+MyDomain.h"
#import "NSError+InfoAccess.h"
#import "NSBundle+MainApp.h"

@implementation NSError (MyDomain)

/*
 @details  This method is for defensive programming, but it may be needed for
 the dylib in our Firefox extension.
 */
+ (NSBundle*)mainAppBundle {
    NSBundle* answer = nil ;
    if ([[NSBundle class] respondsToSelector:@selector(mainAppBundle)]) {
        answer = [NSBundle mainAppBundle] ;
    }
    else {
        answer = [NSBundle mainBundle] ;
    }
    
    return answer ;
}

+ (NSError*)errorWithLocalizedDescription:(NSString*)localizedDescription
									 code:(NSInteger)code
						   prettyFunction:(const char*)prettyFunction {
	NSDictionary* userInfo = nil ;
	if (localizedDescription) {
		NSString* const CFBundleVersionKey = @"Version of Main App Bundle" ;
		userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					localizedDescription, NSLocalizedDescriptionKey,
					[[self mainAppBundle] objectForInfoDictionaryKey:CFBundleVersionKey], CFBundleVersionKey,
					// The following gets added in -[SSYAlert support:].  It would be nice to do it here instead.
					// But then I'd have to #import SSYSystemDescriber into any project using this file.
					//[SSYSystemDescriber softwareVersionString], @"System Description",
					nil] ;
	}
    
	NSError* error = [NSError errorWithDomain:[self myDomain]
										 code:code
									 userInfo:userInfo] ;
    
	error = [error errorByAddingPrettyFunction:prettyFunction] ;
	error = [error errorByAddingTimestampNow] ;
	
	return error ;
}

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

@end
