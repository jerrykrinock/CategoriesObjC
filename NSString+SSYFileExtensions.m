#import "NSString+SSYFileExtensions.h"

@implementation NSString (SSYFileExtensions)

- (NSString*)stringByLossilyAppendingPathExtension:(NSString*)extension {
    if ([extension rangeOfString:@" "].location != NSNotFound) {
        NSMutableString* mutant = [extension mutableCopy] ;
        [mutant replaceOccurrencesOfString:@" "
                                withString:@"_"
                                   options:0
                                     range:NSMakeRange(0, extension.length)] ;
        extension = [mutant copy] ;
#if !__has_feature(objc_arc)
        [extension autorelease] ;
        [mutant release] ;
#endif
    }
    
    return [self stringByAppendingPathExtension:extension] ;
}

@end
