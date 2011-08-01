#import "NSSet+Identicalness.h"

@implementation NSSet (Identicalness)

- (BOOL)isIdenticalToSet:(NSSet*)set {
    if ([self count] != [set count]) {
        return NO ;
    }
    for (id object in self) {
        id match = [set member:object] ;
        if (!match) {
            return NO ;
        }
        if (match != object) {
            return NO ;
        }
    }
	
	return YES ;
}

@end
