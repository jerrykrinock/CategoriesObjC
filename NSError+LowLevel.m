#import "NSError+LowLevel.h"

__attribute__((visibility("default"))) NSString* const SSYAppleScriptErrorDomain = @"SSYAppleScriptErrorDomain" ;

@implementation NSError (LowLevel)

+ (NSError*)errorWithMacErrorCode:(NSInteger)code {
	NSString* domain ;
	NSString* descString ;
	if ((code > 0) && (code < 15)) {
		domain = @"CFStreamErrorDomain" ;
		descString = [NSString stringWithFormat:
					  @"CFStreamError code %d",
					  code] ;
	}
	else if (code < kPOSIXErrorBase) {
		domain = NSOSStatusErrorDomain ;
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_4		
		const char* cString = GetMacOSStatusCommentString(code) ;
#else
		const char* cString = NULL ;
#endif
		if (cString) {
			descString = [NSString stringWithUTF8String:cString] ;
		}
		else {
			descString = [NSString stringWithFormat:
						  @"OSStatus error code %d.  See MacErrors.h",
						  code] ;
		}
	}
	else if (code <= kPOSIXErrorEOPNOTSUPP) {
		domain = NSPOSIXErrorDomain ;
		code -= kPOSIXErrorBase ;
		descString = [NSString stringWithUTF8String:strerror(code)] ;
	}
	// I couldn't find any info on NSMachErrorDomain values
	
	NSError* error= [NSError errorWithDomain:domain
										code:code
									userInfo:nil] ;
	return error ;
}

+ (NSError*)errorWithPosixErrorCode:(NSInteger)code {
	return [self errorWithMacErrorCode:(code+kPOSIXErrorBase)] ;
}

+ (NSError*)errorWithHTTPStatusCode:(int)code 
					 prettyFunction:(const char*)prettyFunction {
	NSString* methodName = [NSString stringWithCString:prettyFunction
											  encoding:NSASCIIStringEncoding] ;
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSHTTPURLResponse localizedStringForStatusCode:code], NSLocalizedDescriptionKey,
							  methodName, @"Method Name",
							  nil] ;
	NSError* error = [NSError errorWithDomain:@"HttpStatusErrorDomain"
										 code:code
									 userInfo:userInfo] ;
	
	return error ;
}

+ (NSError*)errorWithAppleScriptErrorDictionary:(NSDictionary*)dic {
	if (!dic) {
		return nil ;
	}
	
	NSInteger code = [[dic objectForKey:NSAppleScriptErrorNumber] intValue] ;
	NSString* localizedDescription = [dic objectForKey:NSAppleScriptErrorBriefMessage] ;
	// The following is probably not very good, but the best I can think of
	NSString* localizedFailureReason = [dic objectForKey:NSAppleScriptErrorMessage] ;						 
	NSString* appName = [dic objectForKey:NSAppleScriptErrorAppName] ;
	if (!appName) {
		appName = @"Sorry, was not specified" ;
	}
	if (!localizedDescription) {
		localizedDescription = @"Unknown error" ;
	}
	NSString* explanation = @"This error was translated from error info of an attempted AppleScript execution.  Its code = the NSAppleScriptErrorNumber." ;
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  appName, @"From application",                                          // won't be nil
							  explanation, @"ReadMe",                                                // won't be nil
							  localizedDescription, NSLocalizedDescriptionKey,                       // won't be nil
							  [[NSProcessInfo processInfo] processName], @"Process receiving error", // will be, for example, "BookMacster" or "BookMacster-Worker"
							  localizedFailureReason, NSLocalizedFailureReasonErrorKey,              // may be nil
							  nil] ;
	return [NSError errorWithDomain:SSYAppleScriptErrorDomain  // Seems like Apple should provide a constant for this
							   code:code
						   userInfo:userInfo] ;
}

@end