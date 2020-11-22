#import "NSNumber+BooleanDisplay.h"
#import "NSString+LocalizeSSY.h"

@implementation NSNumber (BooleanDisplay)

- (NSString*)booleanDisplayName {
	BOOL boolValue = [self boolValue] ;
	NSString* string ;
	
	if (boolValue == YES) {
        string = [NSString localize:@"yes"];
    } else if (boolValue == NO) {
        string = [NSString localize:@"no"];
    } else {
        string = @"";
	}
	
	return string ;
}


@end
