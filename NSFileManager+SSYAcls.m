#import "NSFileManager+SSYAcls.h"
#import <sys/acl.h>

@implementation NSFileManager (SSYAcls)

- (BOOL)processAcl:(acl_t)acl
{
    NSLog(@"      ACL text is:\n%s", acl_to_text(acl, NULL)) ;
    int returnCode ;
    int entryId = ACL_FIRST_ENTRY ;
    BOOL didDeleteAnyEntry = NO ;
    do {
        NSLog(@"      Requesting next entry") ;
        acl_entry_t acl_entry = NULL ;
        returnCode = acl_get_entry(acl, entryId, &acl_entry) ;
         
        if (returnCode == 0) {
            if (acl_entry != NULL) {
                acl_tag_t tagType = 0 ;
                acl_get_tag_type(acl_entry, &tagType) ;
                if (tagType == ACL_EXTENDED_DENY) {                    
                    int innerReturnCode ;

#if 0
                    // This section is just to see what else I can learn
                    void* qualifier = acl_get_qualifier(acl_entry) ;
                    acl_permset_t permset = NULL ;
                    innerReturnCode = acl_get_permset(acl_entry, &permset) ;
                    
                    NSLog(@"      Got entry:  tagType=%d  qualifier=%p(retCode=%d)  permset=%p",
                          tagType, qualifier, innerReturnCode, permset) ;
                    
                    if (qualifier != NULL) {
                        acl_free(qualifier) ;
                    }
                    // End of Learning section
#endif                    
                    innerReturnCode = acl_delete_entry(acl, acl_entry) ;
                    if (innerReturnCode != 0) {
                        NSLog(@"      Err Deleting ACL : %d", errno) ;
                    }
                    else {
                        NSLog(@"      Successfully deleted entry") ;
                        didDeleteAnyEntry = YES ;
                    }
                }
            }
            else {
                NSLog(@"      NULL entry") ;
            }
        }
        else {
            NSLog(@"      Err getting entry : %d", errno) ;
        }
        
        entryId = ACL_NEXT_ENTRY ;
    } while (returnCode == 0) ;
    
    NSLog(@"      returnCode = %d", returnCode) ;
    
    return didDeleteAnyEntry ;
}

- (acl_t)processAclType:(acl_type_t)aclType path:(const char *)pathC
{
    NSLog(@"   Testing for ACL type %d", aclType) ;
    BOOL didDeleteAnyEntry = NO ;
    acl_t acl = acl_get_file(pathC, aclType) ;
    if (acl != NULL) {
        didDeleteAnyEntry = [self processAcl:acl] ;
        NSLog(@"didDeleteAnyEntry = %d", didDeleteAnyEntry) ;
        acl_free(acl) ;
    }
    else {
        NSLog(@"      ACL type %d is NULL", aclType) ;   
    }
    
    if (!didDeleteAnyEntry) {
        acl = NULL ;
    }
    
    NSLog(@"Returning acl=%p", acl) ;
    return acl ;
}

- (BOOL)removeAclsFromPath:(NSString*)path
                   error_p:(NSError**)error
{
    BOOL ok = YES ;
    const char* pathC = [path fileSystemRepresentation] ;
    
    acl_t acl = [self processAclType:ACL_TYPE_EXTENDED path:pathC] ;
    if (acl != NULL) {
        // The 'acl' which we have obtained and altered is not really the
        // target path's ACL but is in fact an in-memory copy.  We need to
        // now 'set' it into the file.
        // Another alternative, suggested by Chris Suter, is to simply
        // create and 'set' an *empty* ACL.  I haven't tried that but it
        // seems like it would be a better idea if indeed we want to
        // remove *all* entries from path's ACL.
        NSInteger returnCode = acl_set_file(pathC, ACL_TYPE_EXTENDED, acl) ;
        if (returnCode != 0) {
            NSLog(@"Setting ACL returned errno %d", EACCES) ;
        }
        else {
            NSLog(@"Setting ACL returned %ld", returnCode) ;
        }
    }
    
    return ok ;
}

@end
