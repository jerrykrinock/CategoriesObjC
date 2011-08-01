#import "NSManagedObject+Attributes.h"


@implementation NSManagedObject (Attributes)

- (NSSet*)allAttributes {
	return [NSSet setWithArray:[[[self entity] attributesByName] allKeys]] ;
}	

- (NSDictionary*)attributesDictionaryWithNulls:(BOOL)withNulls {
	NSDictionary* answer ;
	if (withNulls) {
		answer = [self dictionaryWithValuesForKeys:[[self allAttributes] allObjects]] ;
		// Note: -dictionaryWithValuesForKeys: puts in the NSNulls.
	}
	else {
		NSMutableDictionary* attributesDic = [[NSMutableDictionary alloc] init] ;
		for (id attributeName in [self allAttributes]) {
			id value = [self valueForKey:attributeName] ;
			if (value) {			
				[attributesDic setValue:value
								 forKey:attributeName] ;			
			}
		}
		
		answer = [attributesDic autorelease] ;
	}
	
	return answer ;
}

- (void)setAttributes:(NSDictionary*)attributes {
	for (id attributeName in attributes) {
		id value = [attributes valueForKey:attributeName] ;
		[self setValue:value
				forKey:attributeName] ;
	}
}


@end
