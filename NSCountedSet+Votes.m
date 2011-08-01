#import "NSCountedSet+Votes.h"


@implementation NSCountedSet (Votes)

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