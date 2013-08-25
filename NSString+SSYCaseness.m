#import "NSString+SSYCaseness.h"

@implementation NSString (SSYCaseness)

- (NSComparisonResult)compareCase:(NSString*)other {
	NSString* selfUpper = [self uppercaseString] ;
	NSString* otherUpper = [other uppercaseString] ;
	NSUInteger end = MIN([self length], [other length]) ;
	for (NSUInteger i=0; i<end; i++) {
		unichar charSelf = [self characterAtIndex:i] ;
		unichar charOther = [other characterAtIndex:i] ;
		if (charSelf != charOther) {
			// Characters are different
			unichar charSelfUpper = [selfUpper characterAtIndex:i] ;
			unichar charOtherUpper = [otherUpper characterAtIndex:i] ;
			BOOL selfIsUpper = (charSelf == charSelfUpper) ;
			BOOL otherIsUpper = (charOther == charOtherUpper) ;
			if (selfIsUpper && !otherIsUpper) {
				return NSOrderedDescending ;
			}
			else if (!selfIsUpper && otherIsUpper) {
				return NSOrderedAscending ;
			}
		}
	}
	
	if ([self length] > [other length]) {
		return NSOrderedDescending ;
	}
    
	if ([self length] < [other length]) {
		return NSOrderedAscending ;
	}
	
	return NSOrderedSame ;
}

@end

