#import <Cocoa/Cocoa.h>


@interface NSMutableSet (CoreDataOrderGlue)

/* This category on NSMutableSet is used to convert the (unordered)
mutable set obtained from -[NSManagedObject mutableSetValueForKey]
into an (ordered) array, and vice versa.   The array is commonly
required to display and edit data, at least in legacy applications
getting a Core Data retrofit.

Here is the problem.  Because Core Data is built on a
relational database, its to-many relationships are (unordered) sets.
Many applications require ordered relationships.  To add order, a
'position' attribute is normally added to each child.  However,
this model breaks down if children may have more than one parent,
and thus different positions in each parent.  The solution is to
interpose a Glue object between the child and parent.  
The Glue object has a to-one relationship to a parent, 
a to-one relationship to a child, and a single attribute, the
position, which is the index of the given child in the given
parent.

This category provides two methods of "glue code", to convert
from Core Data's mutable set, via the Glue object, to the
(ordered) array representation which is commonly required,
and vice versa. 

API: The glueClass must be key-value compliant for orderKey
and payloadKey.  The payloadKey accesses the child value.  */

// The first method is used in the getter of an NSManagedObject,
// to get the array.  (You can obtain the set, which is self, using
// mutableSetValueForKey:)
- (NSArray*)arrayWithOrderKey:(NSString*)orderKey
				   payloadKey:(NSString*)payloadKey ;

	// The second method is used in the setter and is the Inverse
	// of the first method.  It replaces all objects in Mutable Set
	// with the new objects from Array
- (void)setContentsToArray:value
				 glueClass:(Class)glueClass
				  orderKey:(NSString*)orderKey
				payloadKey:(NSString*)payloadKey ;

@end
