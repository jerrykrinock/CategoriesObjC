
#define NSDateIsLaterThan NSOrderedDescending
#define NSDateIsEarlierThan NSOrderedAscending

@implementation NSDate (SafeCompare)

+ (NSDate*)laterDate:(NSDate*)date1
				date:(NSDate*)date2 {
	NSDate* laterDate ;
	if (date1 != nil) {
		if (date2 != nil) {
			laterDate = [date1 laterDate:date2] ;
		}
		else {
			laterDate = date1 ;
		}
	}
	else {
		laterDate = date2 ;
	}
	
	return laterDate ;
}

@end
