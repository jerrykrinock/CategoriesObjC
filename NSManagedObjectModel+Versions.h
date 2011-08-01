#import <Cocoa/Cocoa.h>


@interface NSManagedObjectModel (Versions) 

+ (NSManagedObjectModel*)managedObjectModelWithMomdName:(NSString*)momdName
											versionName:(NSString*)versionName ;

@end
