#import "NSProcessInfo+SSYMoreInfo.h"
#import "SSYSwift-Swift.h"
#import "SSYOtherApper.h"
#import "NSString+SSYExtraUtils.h"
#import <mach/mach.h>
#import <mach/message.h>  // for mach_msg_type_number_t
#import <mach/kern_return.h>  // for kern_return_t
#import <mach/task_info.h>


@implementation NSProcessInfo (SSYMoreInfo)

- (NSDictionary*)geekyProcessInfo {
	NSInteger myPid = [self processIdentifier] ;
	NSString* myPidString = [NSString stringWithFormat:@"%ld", (long)myPid] ;
	
	NSData* stdoutData ;
	NSArray* args ;
	
	args = [NSArray arrayWithObjects:@"-xc", @"-p", myPidString, @"-o", @"ppid=", nil] ;
	// The = after ppid says to print this without a column heading
    NSDictionary* programResults = [SSYTask run:[NSURL fileURLWithPath:@"/bin/ps"]
                                      arguments:args
                                    inDirectory:nil
                                       stdinput:nil
                                        timeout:[SSYOtherApper psTimeout]];
    stdoutData = [programResults objectForKey:SSYTask.stdoutKey];
	
	NSString* parentInfo = @"No ppid" ;
	if (stdoutData) {
		NSString* rawParentInfo = [[NSString alloc] initWithData:stdoutData
									   encoding:[NSString defaultCStringEncoding]] ;
		// Remove the trailing newline
		parentInfo = [rawParentInfo stringByRemovingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] ;
        [rawParentInfo release] ;
		
		args = [NSArray arrayWithObjects:@"-lxww", @"-p", parentInfo, nil] ;
        programResults = [SSYTask run:[NSURL fileURLWithPath:@"/bin/ps"]
                            arguments:args
                          inDirectory:nil
                             stdinput:nil
                              timeout:[SSYOtherApper psTimeout]];
        stdoutData = [programResults objectForKey:SSYTask.stdoutKey];
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

- (NSInteger)currentMemorySizeError_p:(NSError**)error_p {
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    mach_task_basic_info_data_t taskInfo;
    taskInfo.virtual_size = 0;
    taskInfo.resident_size = 0;
    taskInfo.resident_size_max = 0;
    NSInteger size = -1;

    // https://www.gnu.org/software/hurd/gnumach-doc/Task-Information.html
    kern_return_t kernReturn = task_info(
                                         mach_task_self(),  // or current_task(), same thing
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &count
                                         );
    if (kernReturn == KERN_SUCCESS) {
        mach_vm_size_t vsize = taskInfo.virtual_size ;
        /* mach_vm_size_t is a uint64_t.  Cast to NSInteger */
        size = (NSInteger)vsize;
    } else if (error_p) {
        NSString* desc = [[NSString alloc] initWithFormat:
                          @"Could not get memory size due to Mach error %ld",
                          (long)kernReturn];
        *error_p = [NSError errorWithDomain:@"SSYMoreInfoErrorDomain"
                                             code:487538
                                         userInfo:@{NSLocalizedDescriptionKey:desc}];
#if !__has_feature(objc_arc)
        [desc release];
#endif
    }

    return size;
}



@end
