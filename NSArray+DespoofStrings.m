#import "NSString+SSYExtraUtils.h"

@implementation NSArray (DespoofStrings)

- (NSArray*)replaceOccurrencesOfString:(NSString*)target
							withString:(NSString*)replacement {
	//  This is written to be efficient, assuming patches will be rare.
	
	// If any spoofs are found, patches will be a dictionary with
	//   key   = index of string containing one or more target strings
	//   value = string with spoofs replaced by underscore
	NSMutableDictionary* patches = nil ;
	int index = 0 ;
	for (NSString* string in self) {
		if (([string containsString:target])) {
			NSMutableString* newTag = [string mutableCopy] ;
			[newTag replaceOccurrencesOfString:target
									withString:replacement] ;
			if (!patches) {
				patches = [[NSMutableDictionary alloc] init] ;
			}
			[patches setObject:newTag forKey:[NSNumber numberWithInt:index]] ;
			[newTag release] ;
		}
		index++ ;
	}
	
	NSArray* despoofedArray = nil ;
	if (patches) {
		NSMutableArray* newArray = [self mutableCopy] ;
		for (NSNumber* oIndex in patches) {
			[newArray replaceObjectAtIndex:[oIndex intValue]
							   withObject:[patches objectForKey:oIndex]] ;
		}
		[patches release] ;
		
		despoofedArray = [NSArray arrayWithArray:newArray] ;
		[newArray release] ;
	}
	
	return despoofedArray ;
}

@end
