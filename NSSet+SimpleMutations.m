#import "NSSet+SimpleMutations.h"


@implementation NSSet (SimpleMutations)

- (NSSet*)setByRemovingObject:(id)object  {
	NSMutableSet* mutant = [self mutableCopy] ;
	[mutant removeObject:object] ;
	NSSet* newSet = [NSSet setWithSet:mutant] ;
	[mutant release] ;
	
	return newSet ;
}

- (NSSet*)setByRemovingObjectsFromSet:(NSSet*)objects  {
	NSMutableSet* mutant = [self mutableCopy] ;
	[mutant minusSet:objects] ;
	NSSet* newSet = [NSSet setWithSet:mutant] ;
	[mutant release] ;
	
	return newSet ;
}

- (NSSet*)setByTruncatingToCount:(NSInteger)count {
    if ([self count] <= count) {
        return self ;
    }
    
    NSMutableSet* mutaset = [[NSMutableSet alloc] init] ;
    NSInteger i = 0 ;
    for (id object in self) {
        if (i < count) {
            [mutaset addObject:object] ;
            i++ ;
        }
        else {
            break ;
        }
    }
    
    NSSet* set = [mutaset copy] ;
    [mutaset release] ;
    [set autorelease] ;
    
    return set ;
}

@end
