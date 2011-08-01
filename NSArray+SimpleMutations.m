#import "NSArray+SimpleMutations.h"


@implementation NSArray (SimpleMutations)

- (NSArray*)arrayByRemovingObject:(id)object  {
	NSMutableArray* mutant = [self mutableCopy] ;
	[mutant removeObject:object] ;
	NSArray* newArray = [NSArray arrayWithArray:mutant] ;
	[mutant release] ;
	
	return newArray ;
}

- (NSArray*)arrayByInsertingObject:(id)object
						   atIndex:(NSInteger)index {
	NSArray* answer ;
	if (object) {
		NSMutableArray* mutant = [self mutableCopy] ;
		[mutant insertObject:object
					 atIndex:index] ;
		answer = [NSArray arrayWithArray:mutant] ;
	}
	else {
		answer = self ;
	}
	
	return answer ;
}

- (NSArray*)arrayByRemovingObjectAtIndex:(NSUInteger)index  {
	NSMutableArray* mutant = [self mutableCopy] ;
	[mutant removeObjectAtIndex:index] ;
	NSArray* newArray = [NSArray arrayWithArray:mutant] ;
	[mutant release] ;
	
	return newArray ;
}

- (NSArray*)arrayByAddingUniqueObject:(id)object {
	NSArray* array ;
	if ([self indexOfObject:object] == NSNotFound) {
		array = [self arrayByAddingObject:object] ;
	}
	else {
		array = self ;
	}
	
	return array ;	
}

- (NSArray*)arrayByAddingUniqueObjectsFromArray:(NSArray*)array {
	if (!array) {
		return self ;
	}

	NSMutableArray* newArray = [self mutableCopy] ;
	for (id object in array) {
		if ([self indexOfObject:object] == NSNotFound) {
			[newArray addObject:object] ;
		}
	}
	
	NSArray* answer = [newArray copy] ;
	[newArray release] ;
	return [answer autorelease] ;
}

- (NSArray*)arrayByRemovingObjectsEqualPerSelector:(SEL)isEqualSelector {
	NSMutableArray* keepers = [[NSMutableArray alloc] init] ;
	for (id object in self) {
		BOOL isUnique = YES ;
		for (id uniqueObject in keepers) {
			if ([object performSelector:isEqualSelector
							 withObject:uniqueObject]) {
				isUnique = NO ;
				break ;
			}
		}
		
		if (isUnique) {
			[keepers addObject:object] ;
		}
	}
	
	NSArray* answer = [keepers copy] ;
	[keepers release] ;
	
	return [answer autorelease] ;
}

- (NSArray*)arrayByRemovingEqualObjects {
	NSMutableSet* set = [[NSMutableSet alloc] initWithArray:self] ;
	NSMutableArray* keepers = [[NSMutableArray alloc] init] ;
	// set may have fewer objects than self because if a group of
	// objects are -isEqual:, set contains only one of the group.
	for (id objectInArray in self) {
		id objectInSet = [set member:objectInArray] ;
		if (objectInSet) {
			// This is the first object in self which equals
			// this particular objectInSet.  Keep it
			[keepers addObject:objectInArray] ;

			// And remove it from set, so that subsequent objects
			// in self which equal this objectInSet will not
			// be keepers.
			[set removeObject:objectInSet] ;
		}
	}
	
	NSArray* answer = [keepers copy] ;
	[keepers release] ;
	[set release] ;
	
	return [answer autorelease] ;
}


- (NSArray*)arrayIntersectingCollection:(NSObject <NSFastEnumeration> *)collection {
	NSMutableIndexSet* keepers = [[NSMutableIndexSet alloc] init] ;
	for (id object in collection) {
		NSInteger index = [self indexOfObject:object] ;
		if (index != NSNotFound) {
			[keepers addIndex:index] ;
		}
	}
	
	NSArray* newArray = [self objectsAtIndexes:keepers] ;
	[keepers release] ;
	return newArray ;
}

- (NSArray*)arrayMinusCollection:(NSObject <NSFastEnumeration> *)collection {
	NSMutableArray* keepers = [self mutableCopy] ;
	for (id object in collection) {
		NSInteger index = [keepers indexOfObject:object] ;
		if (index != NSNotFound) {
			[keepers removeObjectAtIndex:index] ;
		}
	}
	
	NSArray* newArray = [[keepers copy] autorelease] ;
	[keepers release] ;
	return newArray ;
}

+ (void)mutateAdditions:(NSMutableArray*)additions
			  deletions:(NSMutableArray*)deletions
		   newAdditions:(NSMutableSet*)newAdditions
		   newDeletions:(NSMutableSet*)newDeletions {
	NSSet* immuterator ;
	NSInteger index ;
	
	// Remove from newAdditions and newDeletions any members
	// in these new inputs which cancel one another out
	immuterator = [newAdditions copy] ;
	for (id object in immuterator) {
		id member = [newDeletions member:object] ;
		if (member) {
			[newAdditions removeObject:object] ;
			[newDeletions removeObject:member] ;
		}
	}
	[immuterator release] ;
	
	// Remove from newAdditions any which cancel out existing deletions,
	// and do the cancellation
	immuterator = [newAdditions copy] ;
	for (id object in immuterator) {
		index = [deletions indexOfObject:object] ;
		if (index != NSNotFound) {
			[newAdditions removeObject:object] ;
			[deletions removeObject:object] ;
		}
	}
	[immuterator release] ;
	// Add surviving new additions to existing additions
	[additions addObjectsFromArray:[newAdditions allObjects]] ;
	
	// Remove from newDeletions any which cancel out existing additions,
	// and do the cancellation
	immuterator = [newDeletions copy] ;
	for (id object in immuterator) {
		index = [additions indexOfObject:object] ;
		if (index != NSNotFound) {
			[newDeletions removeObject:object] ;
			[additions removeObject:object] ;
		}
	}
	[immuterator release] ;
	
	// Add surviving new deletions to existing deletions
	[deletions addObjectsFromArray:[newDeletions allObjects]] ;
}

@end