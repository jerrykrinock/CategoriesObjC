#import "NSError+LowLevel.h"

__attribute__((visibility("default"))) NSString* const SSYAppleScriptErrorDomain = @"SSYAppleScriptErrorDomain" ;

@implementation NSError (LowLevel)

+ (NSError*)errorWithMacErrorCode:(OSStatus)code {
	NSString* domain = @"NSError_LowLevel_ErrorDomain" ;
	NSString* descString = nil ;
	if ((code > 0) && (code < 15)) {
		domain = @"CFStreamErrorDomain" ;
        NSInteger intCode = (NSInteger)code ;
		descString = [NSString stringWithFormat:
					  @"CFStreamError code %ld",
					  (long)intCode] ;
	}
	else if (code < kPOSIXErrorBase) {
		domain = NSOSStatusErrorDomain ;
        descString = [[NSError errorWithDomain:NSOSStatusErrorDomain
                                          code:code
                                      userInfo:nil] localizedDescription] ;
        // Unfortunately, the above does not give as much information for
        // as many codes as the deprecated GetMacOSStatusCommentString()  :(
	}
	else if (code <= kPOSIXErrorEOPNOTSUPP) {
		domain = NSPOSIXErrorDomain ;
		code -= kPOSIXErrorBase ;
		descString = [NSString stringWithUTF8String:strerror(code)] ;
	}
	// I couldn't find any info on NSMachErrorDomain values
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              descString, NSLocalizedDescriptionKey,  // may be nil
                              nil] ;
    
    NSError* error = [NSError errorWithDomain:domain
										code:code
									userInfo:userInfo] ;
	return error ;
}

+ (NSError*)errorWithPosixErrorCode:(OSStatus)code {
	return [self errorWithMacErrorCode:(code+kPOSIXErrorBase)] ;
}

+ (NSError*)errorWithHTTPStatusCode:(NSInteger)code 
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
	
	NSInteger code = [[dic objectForKey:NSAppleScriptErrorNumber] integerValue] ;
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
							  [[NSProcessInfo processInfo] processName], @"Process receiving error", // will be, for example, "BookMacster" or "Sheep-Sys-Worker"
							  localizedFailureReason, NSLocalizedFailureReasonErrorKey,              // may be nil
							  nil] ;
	return [NSError errorWithDomain:SSYAppleScriptErrorDomain  // Seems like Apple should provide a constant for this
							   code:code
						   userInfo:userInfo] ;
}

@end