#import "NSNumber+BooleanDisplay.h"
#import "NSString+LocalizeSSY.h"

@implementation NSNumber (BooleanDisplay)

- (NSString*)booleanDisplayName {
	BOOL boolValue = [self boolValue] ;
	NSString* string ;
	
	switch (boolValue) {
		case YES:
			string = [NSString localize:@"yes"] ;
			break ;
		case NO:
			string = [NSString localize:@"no"] ;
			break ;
	}
	
	return string ;
}


@end
