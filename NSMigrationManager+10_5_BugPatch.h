#import <Cocoa/Cocoa.h>


/*!
 @brief    A Workaround for Core Data store migration in applications
 built on 10.6 but that must also run on 10.5

 @details  See:
 "Workaround for Core Data store migration in applications built on
 10.6 but that must also run on 10.5", available here:
 http://developer.apple.com/mac/library/releasenotes/Cocoa/MigrationCrashBuild106Run105/index.html
 
 This class is only required if building apps that must run on 10.5 in 10.6.
*/
@interface NSMigrationManager (_10_5_BugPatch)

@end
