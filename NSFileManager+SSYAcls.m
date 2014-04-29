#import "NSFileManager+SSYAcls.h"
#import <sys/acl.h>

NSString* const SSYAclsErrorDomain = @"SSYAclsErrorDomain" ;

@implementation NSFileManager (SSYAcls)

- (BOOL)removeAclsFromPath:(NSString*)path
                   error_p:(NSError**)error_p {
    BOOL ok = YES ;
    NSError* error = nil ;
    // Seems like there should be a better way to do the following, but the
    // following works (and is indeed necessary)
    if ([path hasPrefix:@"~"]) {
        path = [path substringFromIndex:1] ;
        path = [NSHomeDirectory() stringByAppendingPathComponent:path] ;
    }
    const char* pathC = [path fileSystemRepresentation] ;
    
    // Idea from Chris Suter: Rather than mutating the existing ACLs,
    // because we want them to be all gone, just create a new empty ACL
    // and set it to the desired path.
    acl_t acl = acl_init(0) ;
    NSInteger returnCode = acl_set_file(pathC, ACL_TYPE_EXTENDED, acl) ;
    ok = (returnCode == 0) ;
    acl_free(acl) ;

    if ((returnCode != 0) && (error_p != NULL)) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:returnCode], @"Return Code",
                                  [NSNumber numberWithInteger:errno], @"errno",
                                  @"Failed to clear ACLs", NSLocalizedDescriptionKey,
                                  path, @"Path",
                                  nil] ;
        error = [NSError errorWithDomain:SSYAclsErrorDomain
                                    code:292701
                                userInfo:userInfo] ;
        *error_p = error ;
    }
    
    return ok ;
}

@end
