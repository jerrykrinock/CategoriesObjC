#import <Cocoa/Cocoa.h>

extern NSString* const NSDataFileAliasAliasRecord ;
extern NSString* const NSDataFileAliasPath ;
extern NSString* const NSDataFileAliasError ;

/*!
 @brief    A category on NSData for converting (sometimes "resolving")
 AliasRecord datas to paths, and vice versa, creating AliasRecords

 @details  This category requires Mac OS X 10.5 or later.  Test
 code is provided below.
*/
@interface NSData (FileAlias)

/*!
 @brief    Returns a handle to the receiver's bytes.
*/
- (AliasHandle)aliasHandle ;

/*!
 @brief    Returns the data of an alias record, given a path.

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
 @brief    Invokes pathFromAliasRecordWithTimeout:error_p
 
 @details  First, tries to resolve the alias and returns the resolved
 path.&nbsp;  If the file specified by the receiver does not
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
 TestPath(@"/Users") ;
 TestPath(@"/Users/Ptolemy") ;
 TestPath(@"/Yousers") ;
 TestPath(@"/Volumes/NoSuchVolume") ;
 TestPath(@"/Users/NoSuchFileButParentExists") ;
 TestPath([NSHomeDirectory() stringByAppendingPathComponent:@".DS_Store"]) ;
 TestPath(@"/Applications/Safari.app/Contents/MacOS/Safari") ;
 
 NSLog(@"\n") ;
 NSLog(@"\n") ;
 
 NSLog(@"*** Tests which should fail ***") ;
 TestPath(@"/Users/") ;
 TestPath(@"/Yousers/") ;
 TestPath(@"/Yousers/Ptolemy") ;
 TestPath(@"") ;
 TestPath(@"/") ;
 TestPath(@"/No/Such/File/And/Parent/Does/Not/Exist") ;
 TestPath(@"NotEvenAPath") ;
 
 [pool release] ;
 
 return 0 ;
 }
 
 
*/