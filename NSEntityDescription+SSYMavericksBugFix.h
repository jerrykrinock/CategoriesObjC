#import <CoreData/CoreData.h>

@interface NSEntityDescription (SSYMavericksBugFix)

/*
 @brief    Method to be used in place of -entityForName:inManagedObjectContext:
 which does not work properly in OS X 10.9 if the passed-in name is not a
 constant string.
 
 @details  See this post for more information:
 http://stackoverflow.com/questions/19626858/over-optimization-bug-in-10-9-core-data-entity-description-methods
 */
+ (NSEntityDescription*)SSY_entityForName:(NSString*)name
                   inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext ;

@end
