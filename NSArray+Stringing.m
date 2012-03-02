#import "NSArray+Stringing.h"

@implementation NSArray (Stringing)

- (NSString*)listValuesOnePerLineForKeyPath:(NSString*)keyPath
									 bullet:(NSString*)bullet {
	NSInteger nItems = [self count] ;
	if (!keyPath) {
		keyPath = @"description" ;
	}
	if (!bullet) {
		bullet = @"" ;
	}
	
	NSMutableString* string = [[NSMutableString alloc] init] ;
	int i ;
	for (i=0; i<nItems; i++) {
		NSString* value = [[self objectAtIndex:i] valueForKeyPath:keyPath] ;
		if (value) {
				if ((i>0)) {
				[string appendString:@"\n"] ;
			}
			[string appendFormat:
			 @"%@%@",
			 bullet,
			 value] ;
		}
	}	
	
	NSString* output = [string copy] ;
	[string release] ;
	return [output autorelease] ;
}

- (NSString*)listValuesOnePerLineForKeyPath:(NSString*)keyPath {
	return [self listValuesOnePerLineForKeyPath:keyPath
										 bullet:nil] ;
}

- (NSString*)listValuesForKey:(NSString*)key
				  conjunction:(NSString*)conjunction
				   truncateTo:(NSInteger)truncateTo {
	NSArray* array ;
	BOOL ellipsize = NO ;
	if ((truncateTo > 0) && (truncateTo < [self count])) {
		array = [self subarrayWithRange:NSMakeRange(0, truncateTo)] ;
		ellipsize = YES ;
	}
	else {
		array = self ;
	}
	
	NSInteger nItems = [array count] ;
	NSMutableString* string = [[NSMutableString alloc] init] ;
	int i ;
	for (i=0; i<nItems; i++) {
		id object = [array objectAtIndex:i] ;
		NSString* value = nil ;
		
		if ([object respondsToSelector:NSSelectorFromString(key)]) {
			value = [object valueForKey:key] ;
		}
		else {
			value = [object description] ;
		}

		if (![value isKindOfClass:[NSString class]]) {
			continue ;
		}
		
		if ([value length] == 0) {
			continue ;
		}

		if ((i==(nItems-1)) && (nItems>1) && conjunction) {
			[string appendString:@" "] ;
			if (conjunction) {
				[string appendString:conjunction] ;
			}
			[string appendString:@" "] ;
		}
		else if ((i>0)) {
			[string appendString:@", "] ;
		}
		
		[string appendString:value] ;
	}
	
	if (ellipsize) {
		[string appendFormat:@", %C", 0x2026] ;
	}
	
	NSString* output = [string copy] ;
	[string release] ;
	return [output autorelease] ;
}

- (NSString*)listNames {
	return [self listValuesForKey:@"name"
					 conjunction:nil
					   truncateTo:0] ;
}

@end