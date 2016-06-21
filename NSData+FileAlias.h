#import <Cocoa/Cocoa.h>

extern NSString* const NSDataFileAliasDataKey ;
extern NSString* const NSDataFileAliasPathKey ;
extern NSString* const NSDataFileAliasErrorKey ;
extern NSString* const NSDataFileAliasModernityKey ;
extern NSString* const NSDataFileAliasStalenessKey ;

/*
 Value of NSDataFileAliasModernityKey is an NSNumber whose integer value
 is one of enum NSDataFileAliasModernity.  It is useful for debugging.
 
 Value of NSDataFileAliasStalenessKey is an NSNumber whose integer value
 is one of these:
 NSMixedState : unknown.  Either error, or data was legacy Alias Manager alias.
 NSOnState    : stale.  Data was modern NSURL file bookmark.
 NSOffState   : not stale.  Data was modern NSURL file bookmark.
 */

enum NSDataFileAliasModernity_enum {
    NSDataFileAliasModernityNone = 0,
    NSDataFileAliasModernityLegacyAliasManager = 1,
    NSDataFileAliasModernityNSURLFileBookmark = 2
} ;
typedef enum NSDataFileAliasModernity_enum NSDataFileAliasModernity ;


/*!
 @brief    A category on NSData for converting (sometimes "resolving")
 modern NSURL file bookmarks and legacy Alias Manager AliasRecord datas to
 paths, and vice versa
 
 @details  This category requires macOS 10.6 or later.  Test
 code is provided below.
 */
@interface NSData (FileAlias)

/*!
 @brief    Returns NSURL bookmarks data for a given path, or in macOS
 10.5 or earlier, returns Alias Manager data.
 
 @details  Does not require that the file specified by path exists,
 but at least its parent must exist.&nbsp;
 If file does not exist, but its parent exists, returns a minimal
 alias.&nbsp;
 If file parent does not exist, will return nil.&nbsp;
 This method may be non-deterministic.  Try it twice on the same
 path and you may get a few bits different.&nbsp;  Or, you may not.
 */
+ (NSData*)aliasRecordFromPath:(NSString*)path ;

/*!
 @brief    Tries to resolve a path assuming that the receiver contains an NSURL
 "file bookmark", and if that doesn't produce a result, tries again assuming
 that the receiver contains an old-fashioned Alias Manager file alias record
 
 @details  First, tries to resolve the alias and returns the resolved
 path.  If the file specified by the receiver does not
 exist, extracts the path and returns it.
 By convention, if the alias record specifies a directory,
 the path returned by this method will NOT have a trailing slash.
 @param    timeout  The timeout after which nil will be returned.
 @param    error_p  Pointer which will, upon return, if an error
 occurred and said pointer is not NULL, point to an NSError
 describing said error.
 */
- (NSString*)pathFromAliasRecordWithTimeout:(NSTimeInterval)timeout
                                    error_p:(NSError**)error_p ;

@end

/*  TEST CODE
 
 #import "NSData+FileAlias.h"
 
 void TestPath(NSString* path) {
 NSData* alias = [NSData aliasRecordFromPath:path] ;
 NSString* recoveredPath = [alias pathFromAliasRecordWithTimeout:3.0
 error_p:NULL] ;
 
 if ([path isEqualToString:recoveredPath]) {
 NSLog(@"Passed: %@", path) ;
 }
 else {
 NSLog(@"Failed: %@", path) ;
 NSLog(@"   Got: %@", recoveredPath) ;
 }
 
 }
 
 
 int main(int argc, const char *argv[]) {
 NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init] ;
 
 NSLog(@"*** Tests which should pass ***") ;
 TestPath(@"/") ;
 TestPath(@"/Users") ;
 TestPath([NSHomeDirectory() stringByAppendingPathComponent:@".DS_Store"]) ;
 TestPath(@"/Applications/Safari.app/Contents/MacOS/Safari") ;
 
 NSLog(@"\n") ;
 NSLog(@"\n") ;
 
 NSLog(@"*** Tests which should fail ***") ;
 TestPath(@"/Users/") ;
 TestPath(@"/Yousers/") ;
 TestPath(@"/Yousers/Ptolemy") ;
 TestPath(@"/Users/Ptolemy") ;
 TestPath(@"/Yousers") ;
 TestPath(@"/Volumes/NoSuchVolume") ;
 TestPath(@"/Users/NoSuchFileButParentExists") ;
 TestPath(@"") ;
 TestPath(@"/No/Such/File/And/Parent/Does/Not/Exist") ;
 TestPath(@"NotEvenAPath") ;
 
 [pool release] ;
 
 return 0 ;
 }
 
 
 */
