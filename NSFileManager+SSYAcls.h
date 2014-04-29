#import <Foundation/Foundation.h>

extern NSString* const SSYAclsErrorDomain ;

@interface NSFileManager (SSYAcls)

- (BOOL)removeAclsFromPath:(NSString*)path
                   error_p:(NSError**)error ;

@end

/*
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
*/