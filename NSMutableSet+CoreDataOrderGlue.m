#import "NSMutableSet+CoreDataOrderGlue.h"


@implementation NSMutableSet (CoreDataOrderGlue)

- (NSArray*)arrayWithOrderKey:(NSString*)orderKey
				   payloadKey:(NSString*)payloadKey {
	NSInteger count = [self count] ;
	
	NSMutableArray* array = [[self allObjects] mutableCopy] ;
	
	// But now, since it's an array, we can sort it
	NSSortDescriptor* sortDescriptor ;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:orderKey
												 ascending:YES] ;
	NSArray* sortDescriptors ;
	sortDescriptors = [NSArray arrayWithObject:sortDescriptor] ;
	[sortDescriptor release] ;
	[array sortUsingDescriptors:sortDescriptors] ;
	
	// Finally, replace each objectFromSet with its payload,
	// effectively removing the position value since this
	// information is now carried in the object's index. 
	// Use an old-fashioned C loop since modifying an array while
	// enumerating through it is "not safe"
	NSInteger i ;
	for (i=0; i<count; i++) {
		objectFromSet = [array objectAtIndex:i] ;
		id payloadObject = [objectFromSet valueForKey:payloadKey] ;
		[array replaceObjectAtIndex:i
						 withObject:payloadObject] ;
	}
	
	NSArray* output = [array copy] ;
	[array release] ;
	
	return [output autorelease] ;
}

- (void)setContentsToArray:array
				 glueClass:(Class)glueClass
				  orderKey:(NSString*)orderKey
				payloadKey:(NSString*)payloadKey {
	// Clear out all existing objects in the set
	[self removeAllObjects] ;
	
	// For each object in array,
	NSEnumerator* e = [array objectEnumerator] ;
	id payloadObject ;
	NSInteger i = 0 ;
	while ((payloadObject = [e nextObject])) {
		// Create a glueClass object carrying the
		// payload and augmented with the position
		// and add it to the set
		id glueObject = [[glueClass alloc] init] ;
		NSNumber* position = [[NSNumber alloc] initWithInteger:i] ;
		[glueObject setValue:position forKey:orderKey] ;
		[glueObject setValue:payloadObject forKey:payloadKey] ;
		[self addObject:glueObject] ;
		[glueObject release] ;
		i++ ;
	}
}

@end

/* Test code

// Actual implementation uses managed objects, but that requires a whole Core Data
// stack.  So, for testing I just use regular NSObjects

@interface Gluey : NSObject {
	NSString* _tag ;
	NSString* _bookmark ;
	NSNumber* _position ;
}

@end
@implementation Gluey
SSAOm(NSString*, tag, setTag)
SSAOm(NSString*, bookmark, setBookark)
SSAOm(NSNumber*, position, setPosition)

- (NSString*)description {
	return [NSString stringWithFormat:@"Gluey: pos=%@, tag=%@%", [self position], [self tag]] ;
}

@end

NSArray* tags = [NSArray arrayWithObjects:@"Tom", @"Dick", @"Harry", nil] ;
NSLog(@" array = %@", tags) ;
NSMutableSet* set = [NSMutableSet setWithObjects:@"oldObject0", @"oldObject1", nil] ;
[set setContentsToArray:tags
			  glueClass:[Gluey class]
			   orderKey:@"position"
			 payloadKey:@"tag"] ;
NSLog(@" new set = %@", set) ;
NSArray* loopedBackArray = [set arrayWithOrderKey:@"position"
									   payloadKey:@"tag"] ;


exit(0) ;

*/
