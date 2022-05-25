#import "NSSet+SSYJsonClasses.h"

@implementation NSSet (SSYJsonClasses)

+ (NSSet<Class>*)jsonClasses {
    return [NSSet setWithObjects:
            [NSString class],
            [NSDate class],
            [NSNumber class],
            [NSDictionary class],
            [NSArray class],
            nil
    ];
}

@end

/* Tried to do this in Swift but gave up because it seems like you might
 need to create a class named "Jsonable" for the elements of the set,
 write a hashing function to make it hashable, etc.
 
 @objc
 extension NSSet {
     class func jsonClasses() -> Set<Hashable> { // <- compiler does not like  protocol in the angle brackets
         return Set<AnyHashable>([NSString.self, Date.self, NSNumber.self, [AnyHashable : Any].self, [AnyHashable].self])
     }
 }
 */
