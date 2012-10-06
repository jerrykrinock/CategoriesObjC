#import "NSDictionary+DoNil.h"

@implementation NSDictionary (DoNil)

+ (BOOL)isEqualHandlesNilDic1:(NSDictionary*)dic1
						 Dic2:(NSDictionary*)dic2 {
	BOOL isEqual = NO ;
	if (dic1) {
		if (!dic2) {
			// Documentation for -isEqual does not state if
			// the argument can be nil, so for safety I handle that
			// here, without invoking it.
			
			// dic2 is nil but dic1 is not
			// Leave isEqual as initialized, to NO.
		}
		else {
			isEqual = [dic1 isEqualToDictionary:dic2] ;
		}
	}
	else if (dic2) {
		// dic1 is nil but dic2 is not
		// Leave isEqual as initialized, to NO.
	}
	else {
		isEqual = YES ;
	}
	
	return isEqual ;
}

@end
