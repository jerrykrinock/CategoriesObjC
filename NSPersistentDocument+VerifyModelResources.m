#import "NSPersistentDocument+VerifyModelResources.h"

NSString* SSYPersistentDocumentVerifyModelResourcesErrorDomain = @"SSYPersistentDocumentVerifyModelResourcesErrorDomain" ;

@implementation NSPersistentDocument (VerifyModelResources)

- (BOOL)verifyModelResourcesError_p:(NSError**)error_p {
    BOOL ok = YES ;
    NSError* error = nil ;
    NSArray* modelPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                             inDirectory:nil] ;
    modelPaths = [modelPaths arrayByAddingObjectsFromArray:[[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                                                              inDirectory:nil]] ;
    for (NSString* modelPath in modelPaths) {
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        NSManagedObjectModel* mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] ;
        if (mom) {
#if NO_ARC
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
