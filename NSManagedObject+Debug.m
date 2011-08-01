#import "NSManagedObject+Debug.h"


@implementation NSManagedObject (Debug)

- (NSString*)truncatedID {
	NSManagedObjectID* myID = [self objectID] ;
	NSString* uriStringRep = [[myID URIRepresentation] absoluteString] ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:uriStringRep] ;
	NSString* slashEntityName = [[NSString alloc] initWithFormat:
								 @"/%@",
								 [[self entity] name]] ;
	[scanner scanUpToString:slashEntityName
				 intoString:NULL] ;
	[slashEntityName release] ;
	NSString* truncatedID = @"t?p?" ;  // Fail-safe default value
	if (![scanner isAtEnd]) {
		// The fact that the scanner is not at end means that
		// it must be at the beginning of the string slashEntityName,
		// so we can safely advance the scan location by 6.
		[scanner setScanLocation:[scanner scanLocation] + 6] ;
		if (![scanner isAtEnd]) {
			// Scan up to the final "/"
			[scanner scanUpToString:@"/"
						 intoString:NULL] ;
			if (![scanner isAtEnd]) {
				NSInteger location = [scanner scanLocation] + 1 ;  // +1 for the "/"
				NSInteger length = [uriStringRep length] - location ;
				if (length > 0) {
					NSRange truncatedIDRange = NSMakeRange(location, length) ;
					truncatedID = [uriStringRep substringWithRange:truncatedIDRange] ;
					if ([truncatedID length] > 5) {
						// It's a looooong temporary string, typically
						// truncatedID = "t77470F45-9092-4480-95AB-A6D79F1CE70537"
						NSString* end = [truncatedID substringFromIndex:([truncatedID length] - 4)] ;
						NSString* begin = [truncatedID substringToIndex:1] ;  // first character, "t"
						truncatedID = [NSString stringWithFormat:
										   @"%@'%@",
										   begin,
										   end] ;
					}
				}
			}
		}
	}
	[scanner release] ;
	
	return truncatedID ;
}

@end
