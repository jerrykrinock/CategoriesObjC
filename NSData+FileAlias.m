#import "NSData+FileAlias.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
#import "SSYShellTasker.h"
#import "NSBundle+HelperPaths.h"
#import "NSKeyedUnarchiver+CatchExceptions.h"
#import "NSBundle+MainApp.h"
#import "objc/runtime.h"

//#import "DebugGuy.h"
//extern id debugGuyObject ;



__attribute__((visibility("default"))) NSString* const NSDataFileAliasDataKey = @"aliasRecord" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasPathKey = @"path" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasErrorKey = @"error" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasModernityKey = @"modernity" ;
__attribute__((visibility("default"))) NSString* const NSDataFileAliasStalenessKey = @"staleness" ;


NSString* const NSDataFileAliasWorkerName = @"FileAliasWorker" ;

@implementation NSData (FileAlias)

+ (NSData*)aliasRecordFromPath:(NSString*)path {
    if ([path length] == 0) {
        return nil ;
    }
    
    NSURL* url = [NSURL fileURLWithPath:path] ;
    NSError* error = nil ;
    NSData* data = [url bookmarkDataWithOptions:0
                 includingResourceValuesForKeys:nil
                                  relativeToURL:nil
                                          error:&error] ;
    if (error) {
        // This is expected when the path/URL indicates a file which does
        // not exist.
    }
    
    return data ;
}

- (NSString*)pathFromAliasRecordWithTimeout:(NSTimeInterval)timeout
                                    error_p:(NSError**)error_p {
    NSError* error = nil ;
    NSString* path = nil ;
    
    NSError* taskError = nil ;
    if (!path) {
        error = nil ; // Start over with legacy Alias Manager
        NSDictionary* requestInfo = [NSDictionary dictionaryWithObject:self
                                                                forKey:NSDataFileAliasDataKey] ;
        // Note: It is important that requestInfo and all of its keys and all
        // of its values be encodeable.  The only objects we put in there were
        // an NSString key and an NSData value.
        // Thus, we should be OK to do the following:
        NSData* requestData = [NSKeyedArchiver archivedDataWithRootObject:requestInfo] ;
        
        NSString* workerPath = [[NSBundle mainAppBundle] pathForHelper:NSDataFileAliasWorkerName] ;
        NSData* responseData = nil ;
        NSData* stderrData = nil ;
        NSInteger taskResult = [SSYShellTasker doShellTaskCommand:workerPath
                                                        arguments:nil
                                                      inDirectory:nil
                                                        stdinData:requestData
                                                     stdoutData_p:&responseData
                                                     stderrData_p:&stderrData
                                                          timeout:timeout
                                                          error_p:&taskError] ;
        
        if (!responseData) {
            error = SSYMakeError(59751, @"No stdout from helper") ;
            error = [error errorByAddingUserInfoObject:[NSNumber numberWithInteger:taskResult]
                                                forKey:@"task result"] ;
            error = [error errorByAddingUserInfoObject:stderrData
                                                forKey:@"stderr"] ;
            goto end ;
        }
        
        NSDictionary* responseInfo = [NSKeyedUnarchiver unarchiveObjectSafelyWithData:responseData] ;
        
        if (!responseInfo) {
            error = SSYMakeError(29170, @"Could not decode response from helper") ;
            goto end ;
        }
        
        path = [responseInfo objectForKey:NSDataFileAliasPathKey] ;
        if (!path) {
            NSError* helperError = [responseInfo objectForKey:NSDataFileAliasErrorKey] ;
            error = SSYMakeError(26195, @"Helper returned error") ;
            error = [error errorByAddingUnderlyingError:helperError] ;
        }
        /* If ever needed, return values for NSDataFileAliasModernityKey
         and NSDataFileAliasStalenessKey which are available here, in the
         responseInfo. */
    }
    
end:
    if (error_p) {
        error = [error errorByAddingUnderlyingError:taskError] ;
        *error_p = error ;
    }
    
    return  path ;
}


@end