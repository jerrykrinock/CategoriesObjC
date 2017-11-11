#import "BSManagedDocument+VerifyModelResources.h"
#import "NSBundle+MainApp.h"

NSString* SSYPersistentDocumentVerifyModelResourcesErrorDomain = @"SSYPersistentDocumentVerifyModelResourcesErrorDomain" ;

@implementation BSManagedDocument (VerifyModelResources)

- (BOOL)verifyModelResourcesError_p:(NSError**)error_p {
    BOOL ok = YES ;
    NSError* error = nil ;
    NSArray* modelPaths = [[NSBundle mainAppBundle] pathsForResourcesOfType:@"mom"
                                                             inDirectory:nil] ;
    modelPaths = [modelPaths arrayByAddingObjectsFromArray:[[NSBundle mainAppBundle] pathsForResourcesOfType:@"momd"
                                                                                              inDirectory:nil]] ;
    for (NSString* modelPath in modelPaths) {
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        NSManagedObjectModel* mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] ;
        if (mom) {
#if !__has_feature(objc_arc)
            [mom release] ;
#endif
        }
        else {
            ok = NO ;
            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Data model(s) in app's package are corrupt.", NSLocalizedDescriptionKey,
                                      @"Reinstall this app.", NSLocalizedRecoverySuggestionErrorKey,
                                      modelPath, @"Offending Model Path",
                                      nil] ;
            error = [NSError errorWithDomain:SSYPersistentDocumentVerifyModelResourcesErrorDomain
                                        code:SSYPersistentDocumentVerifyModelResourcesErrorBadResource
                                    userInfo:userInfo] ;
            break ;
        }
    }
    
    if (error && error_p) {
        *error_p = error ;
    }
    
    return ok ;
}

@end
