#import <Foundation/Foundation.h>

@interface NSObject (SSYCheckType)

- (NSError*)errorIfNotClass:(Class)expectedClass
                       code:(NSInteger)code
                      label:(NSString*)label
                 priorError:(NSError*)priorError ;

@end
