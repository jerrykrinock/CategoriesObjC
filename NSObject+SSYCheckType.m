#import "NSObject+SSYCheckType.h"
#import "NSError+MyDomain.h"

@implementation NSObject (SSYCheckType)

- (NSError*)errorIfNotClass:(Class)expectedClass
                       code:(NSInteger)code
                      label:(NSString*)label
                 priorError:(NSError*)priorError {
    NSError* error = priorError ;
    if (!priorError) {
        if (![self isKindOfClass:expectedClass]) {
            NSString* desc = [[NSString alloc] initWithFormat:
                              @"%@ is %@, expected %@",
                              label,
                              self.className,
                              expectedClass.className] ;
            error = SSYMakeError(code, desc) ;
#if !__has_feature(objc_arc)
            [desc release] ;
#endif
        }
    }
    
    return error ;
}

@end
