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

@end
