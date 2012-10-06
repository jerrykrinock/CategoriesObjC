#import "NSCountedSet+Votes.h"

#if 0
NSComparisonResult CompareCounts(id object1, id object2, void* countedSet) {
	NSInteger count1 = [(NSCountedSet*)countedSet countForObject:object1] ;
	NSInteger count2 = [(NSCountedSet*)countedSet countForObject:object2] ;
	NSComparisonResult result ;
	if (count1 < count2) {
		result = NSOrderedDescending ;
	}
	else if (count1 > count2) {
		result = NSOrderedAscending ;
	}
	else {
		result = [object1 compare:object2] ;
	}
	
	return result ;	
}
#endif

@implementation NSCountedSet (Votes)

#if 0
// This method seems to not work properly, then I decided that I didn't need it
- (NSArray*)arrayOrderedByCount {
	NSArray* array = [self allObjects] ;
	array = [array sortedArrayUsingFunction:CompareCounts
									context:self] ;
	return array ;
}
#endif

- (id)winner {
	id winner = nil ;
	NSInteger highestCount = 0 ;
	for (id object in self) {
		NSInteger count = [self countForObject:object] ;
		if (count > highestCount) {
			highestCount = count ;
			winner = object ;
		}
		else if (count == highestCount) {
			winner = nil ;
		}
	}
	
	return winner ;
}

@end


@implementation NSDictionary (Subdictionaries)

- (NSCountedSet*)objectsInSubdictionariesForKey:(id)key
								  defaultObject:(id)defaultObject {
	NSCountedSet* objects = [NSCountedSet set] ;
	for (NSDictionary* subdictionary in [self allValues]) {
		id object = [subdictionary objectForKey:key] ;
		if (object) {
			[objects addObject:object] ;
		}
		else if (defaultObject) {
			[objects addObject:defaultObject] ;
		}
	}
	
	return objects ;
}

@end