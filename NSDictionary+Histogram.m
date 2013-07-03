#import "NSDictionary+Histogram.h"


@implementation NSMutableDictionary (Histogram)

- (void)addInteger:(NSInteger)value
             toKey:(NSString*)key {
    if (value != 0) {
        id currentObject = [self objectForKey:key] ;
        NSInteger newValue ;
        if ([currentObject respondsToSelector:@selector(integerValue)]) {
            newValue = [(NSNumber*)currentObject integerValue] + value ;
        }
        else {
            newValue = value ;
        }
        
        [self setObject:[NSNumber numberWithInteger:newValue]
                 forKey:key] ;
    }
}

@end
