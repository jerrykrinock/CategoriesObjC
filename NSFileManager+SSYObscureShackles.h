#import <Foundation/Foundation.h>

extern NSString* const SSYObscureShacklesErrorDomain ;

@interface NSFileManager (SSYObscureShackles)

/*!
 @brief    Tries to remove any unix File Flags (as in chflags and the "Locked"
 checkbox in Finder's Get Info) and any Access Control List entries (ACLs) and
 from a given path
 
 @details  File Flags and ACLs are the second and third attributes that can
 prevent desired file operations.  They are not as well known as the first one,
 POSIX permissions.  Therefore, they don't cause trouble as often, but when
 they do, they can be a mystery.
 
 Because File Flags seem to trump ACLs, this method tries to remove any File
 Flags first, then ACLs.
 
 For more info on file flags, see man chflags(2).  This method attampts to
 remove both System ("S*") and User ("U*") flags.  The former will probably
 fail without elevated permissions, but you should get an error indicating
 such.  File Flags show in Finder as the "Locked" checkbox in a file's Get Info.
 
 Actually, according to Chris Suter there may be a fourth (MAC Plug-In) and
 fifth (Kauth Plug-In) attributes that can cause trouble:
 
 Jerry: if I simply invoke acl_set_file() at the end of my method per your
 first suggestion, I get an errno=1, inadequate permissions, as you predicted
 and I kind of expected.
 
 Chris Suter: Yeah, you might also find the immutable flag prevents you from
 changing ACLs too, in which case you'll have to temporarily change it.
 It's also possible for a Mandatory Access Control (MAC) plug-in to
 deny you access (e.g. the TMSafetyNet  MAC plugin will prevent you
 from removing ACLs on Time Machine backups) as will the plug-in used
 by the sandbox. A Kauth plug-in might also be able to prevent access.
 
 Kind regards,
 
 Chris Suter <csuter@sutes.co.uk>
 
 This method does not address MAC Plug-Ins or Kauth Plug-Ins.
 
 TODO:  Address the issue of MAC Plug-Ins or Kauth Plug-Ins too.  Learn the
 precedence so that multiple of these gremlins can be succesfully peeled off
 files that have more than one.
 */
- (BOOL)unshacklePath:(NSString*)path
              error_p:(NSError**)error ;

@end
