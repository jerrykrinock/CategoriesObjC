#import "NSManagedObjectModel+Versions.h"
#import "NSBundle+MainApp.h"


@implementation NSManagedObjectModel (Versions)

+ (NSManagedObjectModel*)managedObjectModelWithMomdName:(NSString*)momdName
											versionName:(NSString*)versionName {
	NSString* momdPath = [[NSBundle mainAppBundle] pathForResource:momdName
														 ofType:@"momd"] ;
	NSBundle* modelBundle = [NSBundle bundleWithPath:momdPath] ;
	
	NSString* modelPath = [modelBundle pathForResource:versionName
												ofType:@"mom"] ;
	NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]] ;

	return [model autorelease] ;
}
@end
