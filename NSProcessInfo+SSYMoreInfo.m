#import "NSProcessInfo+SSYMoreInfo.h"
#import "SSYShellTasker.h"
#import "NSString+SSYExtraUtils.h"

@implementation NSProcessInfo (SSYMoreInfo)

- (NSDictionary*)geekyProcessInfo {
	int myPid = [self processIdentifier] ;
	NSString* myPidString = [NSString stringWithFormat:@"%d", myPid] ;
	
	NSData* stdoutData ;
	NSArray* args ;
	
	args = [NSArray arrayWithObjects:@"-xc", @"-p", myPidString, @"-o", @"ppid=", nil] ;
	// The = after ppid says to print this without a column heading
	[SSYShellTasker doShellTaskCommand:@"/bin/ps"
							 arguments:args
						   inDirectory:nil
							 stdinData:nil
						  stdoutData_p:&stdoutData
						  stderrData_p:NULL
							   timeout:5.0
							   error_p:NULL] ;
	
	NSString* parentInfo = @"No ppid" ;
	if (stdoutData) {
		parentInfo = [[NSString alloc] initWithData:stdoutData
									   encoding:[NSString defaultCStringEncoding]] ;
		// Remove the trailing newline
		parentInfo = [parentInfo stringByRemovingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] ;
		
		args = [NSArray arrayWithObjects:@"-lxww", @"-p", parentInfo, nil] ;
		[SSYShellTasker doShellTaskCommand:@"/bin/ps"
								 arguments:args
							   inDirectory:nil
								 stdinData:nil
							  stdoutData_p:&stdoutData
							  stderrData_p:NULL
								   timeout:5.0
								   error_p:NULL] ;
		if (stdoutData) {
			parentInfo = [[NSString alloc] initWithData:stdoutData
										   encoding:[NSString defaultCStringEncoding]] ;
		}
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self arguments], @"Arguments",
			[self environment], @"Environment",
			parentInfo, @"ParentProcessInfo",
			nil] ;	
}



@end