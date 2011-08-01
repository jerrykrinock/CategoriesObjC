#import "SSYTransformStringToAttributed.h"


@implementation SSYTransformStringToAttributed

+ (Class)transformedValueClass {
    return [NSAttributedString class] ;
}

+ (BOOL)allowsReverseTransformation {
    return YES ;
}

- (id)transformedValue:(id)string {
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSFont systemFontOfSize:12.0], NSFontAttributeName,
								[NSColor blackColor], NSForegroundColorAttributeName,
								nil] ;
	if (!string) {
		string = @"" ;
	}
	return [[[NSAttributedString alloc] initWithString:string
											attributes:attributes] autorelease] ;
}

- (id)reverseTransformedValue:(id)attributedString {
	return [attributedString string] ;
}

@end
