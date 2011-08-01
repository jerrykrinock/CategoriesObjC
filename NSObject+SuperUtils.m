#import <objc/objc-runtime.h>
#import "NSObject+SuperUtils.h"

@implementation NSObject (SafeSending)

- (id)safelySendSuperSelector:(SEL)selector 
					arguments:(id)firstArg, ... {
	id returnValue = nil ;
	if (selector) {
		if ([[[self class] superclass] instancesRespondToSelector:selector]) {
			struct objc_super superStruct = {self, [self superclass]} ;
			returnValue = objc_msgSendSuper(&superStruct, selector, firstArg) ;
		}
	}
	return returnValue ;
}

- (id)safelyPerformSelector:(SEL)selector
				 withObject:(id)object {
	id returnValue = nil ;
	if (selector && [self respondsToSelector:selector]) {
		returnValue = [self performSelector:selector
								 withObject:object] ;
	}
	return returnValue ;
}

+ (BOOL)hasOverridden:(SEL)selector {
	IMP subimp = class_getMethodImplementation(self, selector) ;
	Class class = self ;
	do {
		if (class == [NSObject class]) {
			break ;
		}

		Class superclass = [class superclass] ;
		if (![superclass instancesRespondToSelector:selector]) {
			break ;
		}
		
		IMP superimp = class_getMethodImplementation(superclass, selector) ;
		if (superimp != subimp) {
			return YES ;
		}
		
		class = superclass ;
		
	} while (YES) ;
	
	return NO ;
}

@end

