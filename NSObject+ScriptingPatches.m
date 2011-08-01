#import "NSObject+ScriptingPatches.h"

//@interface NSScriptObjectSpecifier (NSScriptObjectSpecifierPrivate) // Private Foundation Methods
//- (NSAppleEventDescriptor *) _asDescriptor;
//@end
//
//#pragma mark * -

@interface NSAEDescriptorTranslator : NSObject // Private Foundation Class
+ (id) sharedAEDescriptorTranslator;
- (NSAppleEventDescriptor *) descriptorByTranslatingObject:(id) object ofType:(id) type inSuite:(id) suite;
@end

#pragma mark * -

// this is needed to coerce custom classes correctly, they act as a safety net
// if these methods get called on a Foundation/AppKit class we call the built-in NSAppleEventDescriptor converters

@implementation NSObject (NSObjectScriptingAdditions)
- (NSAppleEventDescriptor*) scriptingDescriptor {
	NSAppleEventDescriptor* answer ;
	
	//	if( [self isMemberOfClass:[NSAppleEventDescriptor class]] ) {
	//		// NSLog(@"-[NSObject scriptingDescriptor]: scripting descriptor as self") ;
	//		answer = (NSAppleEventDescriptor *) self;
	//	}
	//	
	//	// NSLog( @"*** %@ %s", self, _cmd );
	//	// if this object is custom then we want to return the object specifier
	//	NSScriptObjectSpecifier *objectSpecifier = [self objectSpecifier];
	//	if( objectSpecifier ) {
	//		// NSLog(@"-[NSObject scriptingDescriptor]: scripting descriptor as object specifier") ;
	//		answer = [objectSpecifier _asDescriptor];
	//	}
	
	// don't coerce Foundation/AppKit types to a string, return the correct NSAppleEventDescriptor for them
	// This will execute if the object is an NSDictionary.
	// AppleScript will do the correct coercion later if a string was truley requested
	NSAppleEventDescriptor* descriptor = [[NSAEDescriptorTranslator sharedAEDescriptorTranslator] descriptorByTranslatingObject:self ofType:nil inSuite:nil];
	if(descriptor) {
		// NSLog(@"-[NSObject scriptingDescriptor]: scriptingDescriptor by translating object") ;
		answer = descriptor;
	}
	
	// coerce this into a text representation from the description since it wasn't a coercible Foundation/AppKit type
	// This branch may execute if the object is an NSString.
	// NSLog(@"-[NSObject scriptingDescriptor]: scriptingDescriptor as description") ;
	//	answer = [NSAppleEventDescriptor descriptorWithString:[self description]];
	
	return answer ;
}

//- (NSAppleEventDescriptor *) scriptingTextDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingBooleanDescriptor {
//NSLog( @"*** %@ %s", self, _cmd );
//return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingDateDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingFileDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingIntegerDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingLocationDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingNumberDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingPointDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingRealDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}

- (NSAppleEventDescriptor *) scriptingRecordDescriptor {
	NSLog( @"*** %@ %s", self, _cmd );
	return [self scriptingDescriptor];
}

//- (NSAppleEventDescriptor *) scriptingRectangleDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingSpecifierDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}
//
//- (NSAppleEventDescriptor *) scriptingTypeDescriptor {
//	NSLog( @"*** %@ %s", self, _cmd );
//	return [self scriptingDescriptor];
//}

@end