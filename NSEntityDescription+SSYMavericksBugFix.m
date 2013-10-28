#import "NSEntityDescription+SSYMavericksBugFix.h"

@implementation NSEntityDescription (SSYMavericksBugFix)

+ (NSEntityDescription*)SSY_entityForName:(NSString*)name
                   inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectModel* mom = [[managedObjectContext persistentStoreCoordinator] managedObjectModel] ;
    NSDictionary* entities = [[NSDictionary alloc] initWithDictionary:[mom entitiesByName]] ;
    NSEntityDescription* entityDescription = [entities objectForKey:name] ;
    if (!entityDescription) {
        NSLog(@"Internal Error 282-1983 %@ %@", name, [entities allKeys] );
    }
    [entities release] ;  // Sorry, ARC users
    /*SSYDBL*/ NSLog(@"Got ed with %ld attrs for %@", (long)[[entityDescription attributesByName] count], name) ;
    return entityDescription ;
}

@end

