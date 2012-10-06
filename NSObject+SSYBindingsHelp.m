#import "NSObject+SSYBindingsHelp.h"

@implementation NSObject (SSYBindingsHelp)

- (void)pushBindingValue:(id)value
				  forKey:(NSString*)key {
	NSDictionary* bindingsInfo = [self infoForBinding:key] ;
	id object = [bindingsInfo objectForKey:NSObservedObjectKey] ;
	NSString* bindingsPath = [bindingsInfo objectForKey:NSObservedKeyPathKey] ;
	[object setValue:value
		  forKeyPath:bindingsPath] ;
}

@end
