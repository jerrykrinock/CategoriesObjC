#import "NSData+FileAlias.h"
#import "NSError+InfoAccess.h"
#import "NSError+MyDomain.h"
#import "NSError+LowLevel.h"
#import "SSYShellTasker.h"
#import "NSBundle+HelperPaths.h"
#import "NSBundle+MainApp.h"

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
    
    NSData* requestData = nil;
    if (!error) {
        NSDictionary* requestInfo = [NSDictionary dictionaryWithObject:self
                                                                forKey:NSDataFileAliasDataKey] ;
        // Note: It is important that requestInfo and all of its keys and all
        // of its values be encodeable.  The only objects we put in there were
        // an NSString key and an NSData value.
        // Thus, we should be OK to do the following:
        requestData = [NSKeyedArchiver archivedDataWithRootObject:requestInfo
                                            requiringSecureCoding:YES
                                                            error:&error];
        if (error) {
            error = [SSYMakeError(426190, @"Could not encode request") errorByAddingUnderlyingError:error];
        }
    }
    
    NSData* responseData = nil;
    if (!error) {
        NSString* workerPath = [[NSBundle mainAppBundle] pathForHelper:NSDataFileAliasWorkerName] ;
        NSData* stderrData = nil ;
        NSInteger taskResult = [SSYShellTasker doShellTaskCommand:workerPath
                                                        arguments:nil
                                                      inDirectory:nil
                                                        stdinData:requestData
                                                     stdoutData_p:&responseData
                                                     stderrData_p:&stderrData
                                                          timeout:timeout
                                                          error_p:&error] ;
        
        if (!responseData) {
            error = [SSYMakeError(459751, @"No stdout from helper") errorByAddingUnderlyingError:error];
            error = [error errorByAddingUserInfoObject:[NSNumber numberWithInteger:taskResult]
                                                forKey:@"task result"] ;
            error = [error errorByAddingUserInfoObject:stderrData
                                                forKey:@"stderr"] ;
        }
    }
    
    NSDictionary* responseInfo = nil;
    if (!error) {
        /* Slthough we are unarchiving a dictionary here, per secure coding
         rules, we must also include in the set of allowed classes anything
         which might be in the dictionary. */
        NSSet* classes = [[NSSet alloc] initWithObjects:
                          [NSDictionary class],
                          [NSString class],
                          [NSNumber class],
                          [NSError class],
                          nil];
        responseInfo = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                                           fromData:responseData
                                                              error:&error];
#if !__has_feature(objc_arc)
        [classes release];
#endif
        
        if (!responseInfo) {
            error = [SSYMakeError(429170, @"Could not decode response from helper") errorByAddingUnderlyingError:error];
        }
    }

    if (!error) {
        path = [responseInfo objectForKey:NSDataFileAliasPathKey] ;
        if (!path) {
            error = [responseInfo objectForKey:NSDataFileAliasErrorKey];
            error = [SSYMakeError(426195, @"Helper returned error") errorByAddingUnderlyingError:error];
        }
        /* If ever needed, return values for NSDataFileAliasModernityKey
         and NSDataFileAliasStalenessKey which are available here, in the
         responseInfo. */
    }
    
    if (error && error_p) {
        *error_p = error ;
    }
    
    return  path ;
}


@end
