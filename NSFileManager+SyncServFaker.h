#import <Cocoa/Cocoa.h>

@interface NSFileManager (SyncServFaker)

/*!
 @brief    Waits until there is no Sync Services Lock in the parent
 directory of a given path, then writes its own Sync Services Lock,
 unless a timeout is exceeded.

 @details  A Sync Services Lock is a directory named "lock" in
 a given directory which seems to inhibit other Sync-Services-aware
 applications, and probably Sync Services itself, from writing to
 the directory.&nbsp;  It contains a single plist file named 
 "details.plist" in XML format which contains keys giving the name
 and unix process ID of the process which wrote the file, the time
 the file was written, username under which and hostname in which
 the process was running.
 
 The behavior I see is that if Sync Services or a Sync-Services-aware
 application wants to write a file to a directory, it first checks
 to see if the directory has a Sync Services Lock.&nbsp;  If so, it
 checks to see if the process indicated in its details.plist file is
 alive.&nbsp;  If so, it waits a long time (at least 30 seconds,
 possibly indefinitely) for the Sync Services Lock to be removed.&nbsp; 
 If not, it ignores it.&nbsp;  In either case, it then writes its
 own Sync Services Lock and then, when it is done writing, removes
 the Sync Services Lock, both the details.plist file and the lock
 directory which contains it.&nbsp;
 
 So, the Sync Services Lock seems to provide an effective lock on the
 directory, and also fail-safely removes the lock in case the process
 which acquired the lock crashes.&nbsp; Probably the hostname and 
 username are checked also and compared with the current availability
 and login-edness of these entities.
 
 This method uses NSFileManager and is therefore NOT thread-safe.
 @param    path  The path of the file to be written.&nbsp;  The last path
 component of this path will be ignored, since only the parent directory
 is needed by this method.
 @result   YES if the Sync Services Indicator was written, NO if a 
 timeout occurred.
*/
- (BOOL)acquireSyncServicesLockPath:(NSString*)path
							timeout:(NSTimeInterval)timeout ;

- (void)relinquishSyncServicesLockPath:(NSString*)path ;

@end
