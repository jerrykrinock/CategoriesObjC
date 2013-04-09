#import "NSDictionary+SSYJsonFile.h"
#import "NSError+SSYAdds.h"
#import "NSDictionary+BSJSONAdditions.h"

@implementation NSDictionary (SSYJsonFile)

+ (NSDictionary*)dictionaryFromJsonAtPath:(NSString*)path
                                  error_p:(NSError**)error_p {
    BOOL ok = YES ;
    NSError* error = nil ;
    NSDictionary* dic = nil ;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString* prefsString = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error] ;
        if (!prefsString) {
            ok = NO ;
            error = [SSYMakeError(252391, @"Could not read file") errorByAddingUnderlyingError:error]  ;
        }
        
        if (ok) {
            dic = [NSDictionary dictionaryWithJSONString:prefsString
                                          accurately:NO] ;
        
            if (![dic isKindOfClass:[NSDictionary class]]) {
                ok = NO ;
                error = [SSYMakeError(252392, @"Could not decode JSON in file") errorByAddingUnderlyingError:error]  ;
            }
        }
    }
    else {
        dic = [NSDictionary dictionary] ;
    }
    
    if (!ok) {
        if (error && error_p) {
            error = [error errorByAddingUserInfoObject:path
                                                forKey:@"Path"] ;
            *error_p = error ;
            dic = nil ;
        }
    }
    
    return dic ;
}

@end
