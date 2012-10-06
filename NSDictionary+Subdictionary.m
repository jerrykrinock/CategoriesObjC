#import "NSDictionary+Subdictionary.h"


@implementation NSDictionary (Subdictionary)

- (NSDictionary*)subdictionaryWithKeys:(NSArray*)keys {
	//  Probably premature optimization…
	//	if ([[NSSet setWithArray:[self allKeys]] isEqualToSet:[NSSet setWithArray:keys]]) {
	//		return self ;
	//	}
	
	NSMutableDictionary* mutant = [[NSMutableDictionary alloc] init] ;
	for (id key in keys) {
		[mutant setValue:[self objectForKey:key]
				  forKey:key] ;
	}
	
	NSDictionary* answer = [[mutant copy] autorelease] ;
	[mutant release] ;
	
	return answer ;
}

@end
