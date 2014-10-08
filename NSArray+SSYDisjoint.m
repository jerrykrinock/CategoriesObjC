#import "NSArray+SSYDisjoint.h"

@interface SSYDisjoiningPlaceholder : NSObject
@end
@implementation SSYDisjoiningPlaceholder
@end

@implementation NSMutableArray (SSYDisjoint)

- (void)putObject:(id)object
          atIndex:(NSUInteger)index {
    NSInteger count = [self count] ;
    if (index < count) {
        [self replaceObjectAtIndex:index
                        withObject:object] ;
    }
    else {
        if (index > count) {
            SSYDisjoiningPlaceholder* placeholder = [[SSYDisjoiningPlaceholder alloc] init] ;
            for (NSInteger i = [self count] ; i < index ; i++) {
                [self addObject:placeholder] ;
            }
            [placeholder release] ;
        }
        
        [self addObject:object] ;
    }
}

- (void)cleanObjectAtIndex:(NSInteger)index {
    SSYDisjoiningPlaceholder* placeholder = [[SSYDisjoiningPlaceholder alloc] init] ;
    [self replaceObjectAtIndex:index
                    withObject:placeholder] ;
    [placeholder release] ;

    NSInteger count = [self count] ;
    NSInteger lastIndexToKeep = count - 1 ;
    for ( ; lastIndexToKeep>=0; lastIndexToKeep--) {
        if (![[self objectAtIndex:lastIndexToKeep] isKindOfClass:[SSYDisjoiningPlaceholder class]]) {
            break ;
        }
    }
    
    NSInteger lengthToRemove = count - lastIndexToKeep - 1;
    if ((lengthToRemove > 0) && (lastIndexToKeep < count - 1)) {
        NSInteger firstIndexToRemove = lastIndexToKeep + 1 ;
        NSRange range = NSMakeRange(firstIndexToRemove, lengthToRemove) ;
        [self removeObjectsInRange:range] ;
    }
}

@end

