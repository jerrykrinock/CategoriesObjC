#import "NSArray+SortDescriptorsHelp.h"

@implementation NSArray (SortByKey)

+ (NSArray*)sortDescriptorsForStringValueForKey:(NSString*)key {
	NSSortDescriptor* sortDescriptor ;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
												 ascending:YES
												  selector:@selector(localizedCaseInsensitiveCompare:)] ;
	NSArray* sortDescriptors ;
	sortDescriptors = [NSArray arrayWithObject:sortDescriptor] ;
	[sortDescriptor release] ;
	
	return sortDescriptors ;
}

- (NSArray*)arraySortedByStringValueForKey:(NSString*)key {
	return [self sortedArrayUsingDescriptors:[NSArray sortDescriptorsForStringValueForKey:key]] ;
}

- (NSArray*)arraySortedByKeyPath:(NSString*)keyPath {
    if (!keyPath) {
		keyPath = @"description" ;
	}
	
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyPath
																   ascending:YES] ;
    NSArray* orderedArray = [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release] ;
	return orderedArray ;
}

@end

@implementation NSMutableArray (SortByKey) 

- (void)sortByStringValueForKey:(NSString*)key {
	NSArray* sortDescriptors = [NSArray sortDescriptorsForStringValueForKey:key] ;
	[self sortUsingDescriptors:sortDescriptors] ;
}

@end