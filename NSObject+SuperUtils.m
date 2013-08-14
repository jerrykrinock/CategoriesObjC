#import "NSObject+SuperUtils.h"
#import <objc/objc-runtime.h>

#define Q(x) #x
#define QUOTE(x) Q(x)

#ifdef FILE_ARG
#include QUOTE(FILE_ARG)
#endif


@interface NSString (SSYParsePrettyFunction)

/*
 @brief    Given an Objective-C symbol name for an instance or class method,
 of the form -[Foo bar], or +[Foo(Baz) bar1:bar2:etc:], or somethwere in
 between these two, extracts and returns the class name
 
 @details  For both of the examples given above, this method returns @"Foo".
 
 @param    prettyFunction  The symbol name from which the class name will be
 extracted.  We call it prettyFunction because you usually get it by passing
 simply the preprocessor macro __PRETTY_FUNCTION__ with no quotes.
 */
+ (NSString*)extractClassNameFromPrettyFunction:(const char*)prettyFunction ;

@end

@implementation NSString (SSYParsePrettyFunction)

+ (NSString*)extractClassNameFromPrettyFunction:(const char*)prettyFunction {
    NSString* fragment = [NSString stringWithUTF8String:prettyFunction] ;
    fragment = [fragment substringFromIndex:2] ;
    NSCharacterSet* characterSet =  [NSCharacterSet characterSetWithCharactersInString:@" ("] ;
    NSScanner* scanner = [[NSScanner alloc] initWithString:fragment] ;
    NSString* answer ;
    [scanner scanUpToCharactersFromSet:characterSet
                            intoString:&answer] ;
    [scanner release] ;
    return answer ;
}

@end


@implementation NSObject (SafeSending)

- (id)safelySendSuperSelector:(SEL)selector
               prettyFunction:(const char*)prettyFunction
					arguments:(id)firstArg, ... {
	id returnValue = nil ;
	if (selector) {
        NSString* className = [NSString extractClassNameFromPrettyFunction:prettyFunction] ;
        Class superclass = [NSClassFromString(className) superclass] ;
		if ([superclass instancesRespondToSelector:selector]) {
			struct objc_super superStruct = {self, superclass} ;
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

