#import "NSFileManager+SSYFileDescriptor.h"
@import SSYSwift;


NSString* const SSYFileManagerFileDescriptorErrorDomain = @"SSYFileManagerFileDescriptorErrorDomain" ;

@implementation NSFileManager (SSYFileDescriptor)

+ (NSString*)pathForFileDescriptor:(NSInteger)fileDescriptor
							   pid:(pid_t)pid
						   error_p:(NSError**)error_p {
	if (!pid) {
		pid = [[NSProcessInfo processInfo] processIdentifier] ;
	}
	
    NSArray* args = [NSArray arrayWithObjects:
                     @"-Fn",  // output only the process 'name' (n)
                     @"-w",   // suppress warnings
                     @"-a",   // logical-AND the next two arguments
                     [NSString stringWithFormat:@"-p%ld", (long)pid],
                     [NSString stringWithFormat:@"-d%ld", (long)fileDescriptor],
                     nil];
	NSData* stdoutData = nil ;
	NSData* stderrData = nil ;
	NSError* error = nil ;
    NSDictionary* programResults = [SSYTask run:[NSURL fileURLWithPath:@"/usr/sbin/lsof"]
                                      arguments:args
                                    inDirectory:nil
                                       stdinput:nil
                                        timeout:5.0];
    NSInteger programExitStatus = [[programResults objectForKey:SSYTask.exitStatusKey] integerValue];
    stdoutData = [programResults objectForKey:SSYTask.stdoutKey];

	NSMutableDictionary* errorInfo = [[NSMutableDictionary alloc] init] ;
	
	NSInteger errorCode = 0 ;
	NSString* path = nil ;
	if (programExitStatus == EXIT_SUCCESS) {
		if (stdoutData) {
			NSString* lsofOutput = [[NSString alloc] initWithData:stdoutData
														 encoding:NSUTF8StringEncoding] ;
			if (lsofOutput) {
				// lsofOutput will be two lines, like this:
				// p<pid>
				// n</path/we/want>
				NSArray* lsofLines = [lsofOutput componentsSeparatedByString:@"\n"] ;
				for (NSString* line in lsofLines) {
					if ([line hasPrefix:@"n"] && [line length] > 1) {
						path = [line substringFromIndex:1] ;
						break ;
					}
				}
				
				if (!path) {
					errorCode = 647701 ;
					[errorInfo setObject:lsofLines
								  forKey:@"Lines"] ;
				}
			}
			else {
				errorCode = 644702 ;
				[errorInfo setObject:stdoutData
							  forKey:@"Stdout"] ;
			}
			
			[lsofOutput release] ;
		}
		else {
			errorCode = 644703 ;			
		}
	}
	else {
		errorCode = 644704 ;			
		[errorInfo setObject:[NSNumber numberWithInteger:programExitStatus]
					  forKey:@"Cmd Exit Status"] ;
		[errorInfo setValue:error
					 forKey:NSUnderlyingErrorKey] ;
	}
	
	if (error_p && (errorCode != 0)) {
		[errorInfo setObject:@"Could not get path"
					 forKey:NSLocalizedDescriptionKey] ;
		[errorInfo setObject:[NSNumber numberWithInteger:pid]
					 forKey:@"Pid"] ;
		[errorInfo setObject:[NSNumber numberWithInteger:fileDescriptor]
					 forKey:@"FD"] ;
		[errorInfo setValue:[[[NSString alloc] initWithData:stderrData
												   encoding:NSASCIIStringEncoding] autorelease]
					 forKey:@"Stderr"] ;
		*error_p = [NSError errorWithDomain:SSYFileManagerFileDescriptorErrorDomain
									   code:errorCode
								   userInfo:errorInfo] ;
	}
    
    [errorInfo release] ;
		 
	return path ;
}


@end
