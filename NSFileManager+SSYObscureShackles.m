#import "NSFileManager+SSYObscureShackles.h"
#import <sys/acl.h>
#import <sys/stat.h>
#import <unistd.h>

NSString* const SSYObscureShacklesErrorDomain = @"SSYObscureShacklesErrorDomain" ;

@implementation NSFileManager (SSYObscureShackles)

- (BOOL)unshacklePath:(NSString*)path
              error_p:(NSError**)error_p {
    BOOL ok = YES ;
    NSError* error = nil ;
    NSInteger returnCode ;
    
    // Seems like there should be a better way to do the following, but the
    // following works (and is indeed necessary, at least for acl_set_file())
    if ([path hasPrefix:@"~"]) {
        path = [path substringFromIndex:1] ;
        path = [NSHomeDirectory() stringByAppendingPathComponent:path] ;
    }
    const char* pathC = [path fileSystemRepresentation] ;
    
    // First, try to clear File Flags
    returnCode = chflags(pathC, 0x0) ;  // 0x0 says to clear all flags
    ok = (returnCode == 0) ;
    if (ok == NO) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:returnCode], @"Return Code",
                                  [NSNumber numberWithInteger:errno], @"errno",
                                  @"Failed to clear File Flags", NSLocalizedDescriptionKey,
                                  path, @"Path",
                                  nil] ;
        error = [NSError errorWithDomain:SSYObscureShacklesErrorDomain
                                    code:297801
                                userInfo:userInfo] ;
    }
    else {
        // OK, continue on to clear ACLs
        
        /* Idea from Chris Suter: Rather than mutating the existing ACLs,
         because we want them to be all gone, just create a new empty ACL
         and set it to the desired path. */
        acl_t acl = acl_init(0) ;
        returnCode = acl_set_file(pathC, ACL_TYPE_EXTENDED, acl) ;
        ok = (returnCode == 0) ;
        acl_free(acl) ;

        if (ok == NO) {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:returnCode], @"Return Code",
                                      [NSNumber numberWithInteger:errno], @"errno",
                                      @"Failed to clear ACLs", NSLocalizedDescriptionKey,
                                      path, @"Path",
                                      nil] ;
            error = [NSError errorWithDomain:SSYObscureShacklesErrorDomain
                                        code:297802
                                    userInfo:userInfo] ;
        }
    }
    

    if (error && error_p) {
        *error_p = error ;
    }
    
    return ok ;
}

@end
