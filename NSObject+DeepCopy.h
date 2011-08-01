#import <Cocoa/Cocoa.h>

/*!
 @brief    Categories for making mutable deep copies of dictionaries,
 arrays and sets.
 
 @details   The original author says that this doesn't work:
 "... for the life of me I can't figure out why, it seems that -copy
 is always a copy of the pointers. Examining two dictionaries in the
 debugger using this method shows that the objects have different
 pointers but their components are identical, STILL. So it seems not
 to work."
 
 I don't know what he/she means.  It seems to work fine for me.
 
 Note that another way to make a deep copy is 
 make an archive of it and immediately unarchive it into a
 different variable. The only down-side is that the object to
 be copied must implement NSCoding ^and^ be encodeable.
 
 To do that,
 id foo = ... ;
 NSData* fooArchive = [NSKeyedArchiver archivedDataWithRootObject:foo] ;
 id fooCopy = [NSKeyedUnarchiver unarchiveObjectSafelyWithData:fooArchive] ;
 
 Source: http://www.cocoadev.com/index.pl?MutableDeepCopyAndUserDefaults
 */

/*!
 @brief    A category of NSObject which produces deep copies
 of collections containing dictionaries, arrays and/or sets.
 
 @details  
 */


/*!
 @brief    Rule for how to copy leaf nodes when making a deep copy.

 @details  These are listed in order from least stringent
 to most stringent.
*/
typedef NSInteger SSYDeepCopyStyleBitmask ;

extern SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskCopy ;
extern SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskMutable ;
extern SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskEncodeable ;
extern SSYDeepCopyStyleBitmask const SSYDeepCopyStyleBitmaskSerializable ;

@interface NSObject (DeepCopy)

/*!
 @brief    Returns a deep, mutable copy of the receiver with an extra
 retain count that you must release.
 
 @details  If an object responds to -mutableCopyWithZone and 
 -count, it is treated as a container node.&nbsp; and processed
 in a subclass category under the hood.
 
 Leaf nodes are treated as follows:
 <ul>
 <li>If the style mask specifies serializable but an object is not
 serializable, its image in the returned result will be its
 -longDescription.</li>
 <li>Else, if the style mask specifies encodeable but an object raises
 an exception when we try to encode it with NSKeyedArchiver, its image
 in the returned result will be its -longDescription.</li>
 <li>Else, if the style mask specifies mutable and the object responds
 to -mutableCopyWithZone:, its image in the returned result will be a
 mutable copy of the object.</li>
 <li>Else, if the style mask specifies copy and the object responds to
 -copyWithZone:, its image the returned result will be a copy
 of the object.</li>
 <li>Else, its image in the returned result is the object itself.</li>
 </ul>
 
 @param    style  Determines the makeup of non-collection
 objects in the result */
- mutableDeepCopyStyle:(SSYDeepCopyStyleBitmask)style;

@end

#ifdef TEST_CODE_FOR_NSOBJECT_DEEP_CLONING

#import "NSDictionary+KeyPaths.h"
#import "NSObject+DeepCopy.h"

@interface Foo : NSObject {
	
}

@end

@implementation Foo

- (NSString*)description {
	return @"This is a Foo." ;
}

@end


int main(int argc, const char *argv[]) {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init] ;
	NSMutableDictionary* md = [NSMutableDictionary dictionary] ;
	[md setValue:@"red"
	  forKeyPath:@"meals.lunch.fruit.color"] ;
	[md setValue:[[[Foo alloc] init] autorelease]
	  forKeyPath:@"meals.lunch.cheese.color"] ;
	NSLog(@"original = %@", md) ;
	
	NSMutableDictionary* mdc = [md mutableDeepCopyStyle:SSYDeepCopyStyleBitmaskSerializable] ;
	NSLog(@"mdc = %@", mdc) ;
	
	
	[pool release] ;
	
	return 0 ;
}


#endif