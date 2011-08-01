#import "NSKeyedUnarchiver+CatchExceptions.h"
#import <objc/runtime.h>
#import "NSError+SSYAdds.h"

@implementation NSKeyedUnarchiver (CatchExceptions)

+ (id)unarchiveObjectSafelyWithData:(NSData*)data
							error_p:(NSError**)error_p {
	id object = nil ;
	NSError* error = nil ;
	if (data) {
		@try {
			object = [self unarchiveObjectWithData:data] ;
		}
		@catch (NSException* exception) {
			error = SSYMakeError(393831, @"Exception unarchiving data") ;
			error = [error errorByAddingUnderlyingException:exception] ;
			object = nil ;
		}
		@finally{
		}
	}
	else {
		error = SSYMakeError(393830, @"Nil data to unarchive") ;
	}
	
	if (error && error_p) {
		*error_p = error ;
	}
	
	return object ;
}

+ (id)unarchiveObjectSafelyWithData:(NSData*)data {
	NSError* error = nil ;
	id object = [self unarchiveObjectSafelyWithData:data
											error_p:&error] ;
	if (error) {
		NSLog(@"Error unarchiving data: %@", [error longDescription]) ;
	}
	
	return object ;
}

@end