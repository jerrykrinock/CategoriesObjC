#import <Cocoa/Cocoa.h>


@interface NSAppleScript (ThreadSafe)

/*!
 @brief    Executes an AppleScript source on the main thread,
 returning after the execution is complete.

 @param    source  
 @param    error_p  If an error occurs, and if error_p is not
 nil, a descriptive error object will be assigned to *error_p.
 @result   YES if the script completed without error, otherwise
NO.
*/
+ (BOOL)threadSafelyExecuteSource:(NSString*)source
						  error_p:(NSError**)error_p ;

@end

#if 0
// Here is some code that I found, but ended up not using, to 
// execute a script with parameters passed.  It comes from here:
// http://www.cocoadev.com/index.pl?CallAppleScriptFunction
// Author is Benoît Marchal
// http://www.marchal.com/en/
// http://www.cocoadev.com/index.pl?BenoitMarchal

First, the demo AppleScript resource:

on show_message(user_message)
   tell application "Finder"
      display dialog user_message
   end tell
end show_message

// Now, the Cocoa code

NSDictionary *errors = [NSDictionary dictionary];
NSString *path = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"scpt"];
if(path)
{
	NSURL *url = [NSURL fileURLWithPath:path];
	if(url)
	{
		// load the script from a resource
		NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
		if(appleScript)
		{
			// create the first (and in this case only) parameter
			// note we can't pass an NSString (or any other object
			// for that matter) to AppleScript directly,
			// must convert to NSAppleEventDescriptor first
			NSAppleEventDescriptor *firstParameter = [NSAppleEventDescriptor descriptorWithString:@"my message"];
			// create and populate the list of parameters
			// note that the array starts at index 1
			NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
			[parameters insertDescriptor:firstParameter atIndex:1];
			// create the AppleEvent target
			ProcessSerialNumber psn = { 0, kCurrentProcess };
			NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber
																							bytes:&psn
																						   length:sizeof(ProcessSerialNumber)];
			// create an NSAppleEventDescriptor with the method name
			// note that the name must be lowercase (even if it is uppercase in AppleScript)
			NSAppleEventDescriptor *handler = [NSAppleEventDescriptor descriptorWithString:[@"show_message" lowercaseString]];
			// last but not least, create the event for an AppleScript subroutine
			// set the method name and the list of parameters
			NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
																					 eventID:kASSubroutineEvent
																			targetDescriptor:target
																					returnID:kAutoGenerateReturnID
																			   transactionID:kAnyTransactionID];
			[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
			[event setParamDescriptor:parameters forKeyword:keyDirectObject];
			// at last, call the event in AppleScript
			if(![appleScript executeAppleEvent:event error:&errors]);
            ReportAppleScriptErrors(errors);
			[appleScript release];
		}
		else {
			ReportAppleScriptErrors(errors);
		}
	}
}
#endif