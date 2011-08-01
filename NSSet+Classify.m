

@implementation NSSet (Classify)

- (void)classifyByClassIntoSetsInDictionary:(NSMutableDictionary*)dic {
	for (id object in self) {
		Class class = [object class] ;
		// Since a Class is not an object and does not conform to NSCopying,
		// we cannot use it as a key.
		NSString* key = NSStringFromClass(class) ;
		NSMutableSet* bin = [dic objectForKey:key] ;
		if (!bin) {
			bin = [[NSMutableSet alloc] init] ;
			[dic setObject:bin
					forKey:key] ;
			[bin release] ;
		}
		[bin addObject:object] ;
	}	
}

@end
