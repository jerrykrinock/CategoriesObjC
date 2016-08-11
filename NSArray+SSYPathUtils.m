#import "NSArray+SSYPathUtils.h"
#import "NSString+MorePaths.h"
#import "NSArray+SSYMutations.h"

@implementation NSArray (SSYPathUtils)

- (NSArray*)pathsByRemovingDescendants {
    NSArray* sortedPaths = [self sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] ;
    NSMutableSet* pathsToRemove = [NSMutableSet new] ;
    for (NSString* path in sortedPaths) {
        if ([pathsToRemove member:path] == nil) {
            for (NSString* root in sortedPaths) {
                if ([pathsToRemove member:root] == nil) {
                    if ([path pathIsDescendantOf:root]) {
                        [pathsToRemove addObject:path] ;
                        break ;
                    }
                }
            }
        }
    }
    
    NSArray* answer = [self arrayByRemovingObjectsFromSet:pathsToRemove] ;
    [pathsToRemove release] ;

    return answer ;
}


@end
