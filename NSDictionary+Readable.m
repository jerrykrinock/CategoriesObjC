
@implementation NSDictionary (Readable)

- (NSString*)readable {
	NSMutableString* list = [[NSMutableString alloc] init] ;
	BOOL atLeastOne = NO ;
	
	// Create string, formatted as list
	for (id key in self) {
		NSString* lineItem = [[NSString alloc] initWithFormat:@"%@: %@\n", 
							  key,
							  [self objectForKey:key]] ;
		[list appendString:lineItem] ;
		[lineItem release] ;
		atLeastOne = YES ;
	}
	
	if (atLeastOne) {
		// delete trailing newline
		[list deleteCharactersInRange:NSMakeRange([list length] - 1, 1)] ;
	}
	
	NSString* output = [list copy] ;
	[list release] ;
	return [output autorelease] ;
}

@end
