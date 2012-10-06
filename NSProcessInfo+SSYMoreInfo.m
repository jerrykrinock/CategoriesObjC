#import "NSProcessInfo+SSYMoreInfo.h"
#import "SSYShellTasker.h"
#import "NSString+SSYExtraUtils.h"

@implementation NSProcessInfo (SSYMoreInfo)

- (NSDictionary*)geekyProcessInfo {
	NSInteger myPid = [self processIdentifier] ;
	NSString* myPidString = [NSString stringWithFormat:@"%ld", (long)myPid] ;
	
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
		NSString* rawParentInfo = [[NSString alloc] initWithData:stdoutData
									   encoding:[NSString defaultCStringEncoding]] ;
		// Remove the trailing newline
		parentInfo = [rawParentInfo stringByRemovingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] ;
        [rawParentInfo release] ;
		
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
			parentInfo = [[[NSString alloc] initWithData:stdoutData
										   encoding:[NSString defaultCStringEncoding]] autorelease] ;
		}
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self arguments], @"Arguments",
			[self environment], @"Environment",
			parentInfo, @"ParentProcessInfo",
			nil] ;	
}



@end