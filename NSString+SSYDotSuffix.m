#import "NSString+SSYDotSuffix.h"

@implementation NSString (SSYFileExtensions)

- (NSString*)stringByAppendingDotSuffix:(NSString*)suffix {
    NSString* answer ;
    if (suffix) {
        answer = [self stringByAppendingFormat:@".%@", suffix] ;
    }
    else {
        answer = self ;
    }
    
    return answer ;
}

- (NSString*)stringByDeletingDotSuffix {
    NSArray* components = [self componentsSeparatedByString:@"."] ;
    NSString* answer ;
    if (components.count < 2) {
        answer = self ;
    }
    else if (components.count == 2) {
        answer = components.firstObject ;
    }
    else {
        components = [components subarrayWithRange:NSMakeRange(0, components.count - 1)] ;
        answer = [components componentsJoinedByString:@"."] ;
    }
    
    return answer ;
}
@end
