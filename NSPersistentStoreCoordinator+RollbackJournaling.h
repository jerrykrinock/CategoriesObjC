#import <CoreData/CoreData.h>

/*
 @brief    Aids in building a Core Data project to use "rollback" aka "delete"
 journaling mode in its SQLite stores when building with the OS X 10.9 or iOS 7
 SDK
 
 @details  Forcing a Core Data project to use "rollback" aka "delete" journaling
 mode in its sqlite stores when building with the OS X 10.9 or iOS 7 SDK is easy
 except for finding all of places where persistent stores have been added and
 ensuring that you have inserted the option
 *   @{ NSSQLitePragmaOptions : @{ @"journal_mode" : @"DELETE" } }
 into each and every one.  This category helps you do that.
 
 INSTRUCTIONS
 
 * Add to any Core Data project that you want to be using legacy
 "rollback" aka "delete" journaling mode for its sqlite stores.
 * Use +dictionaryByAddingSqliteRollbackToDictionary to add the rollback/delete
 entry to the options dictionary wherever you add a persistent store
 coordinator.
 * Build your product in debug configuration using the Mac OS X 10.9
 or iOS 7 or later SDK.
 * Run your product through its creation, opening and migrating of SQLite
 stores.  The swizzled methods in this class will log an error to stderr if
 your product ever creates, opens or migrates an SQLite store without the
 required pragma.
 
 Note that the method swizzling and logging only is #if DEBUG, so that it 
 only gets compiled into debug builds.
 
 ACKNOWLEDGMENTS
 
 For the swizzling code: Ziqiao Chen, Romain Piveteau.
 */
@interface NSPersistentStoreCoordinator (RollbackJournaling)

/*!
 @brief    Returns a dictionary containing the entries of a given dictionary,
 and also a new entry which tells Core Data to create a persistent store using
 legacy "rollback" aka "delete" journal mode, instead if "write-ahead logging"
 aka "WAL" mode which is the default when building with the Mac OS X 10.9
 or iOS 7 SDK or later.
 
 @param    optionsIn  May be nil, in which case the result contains only the
 new entry. */
+ (NSDictionary*)dictionaryByAddingSqliteRollbackToDictionary:(NSDictionary*)optionsIn ;

@end

