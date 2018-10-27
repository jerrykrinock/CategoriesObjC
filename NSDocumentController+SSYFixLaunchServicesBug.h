#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDocumentController (SSYFixLaunchServicesBug)

/*
 @brief    Ensures that Launch Services passes the correct document typeName
 to makeDocumentForURL:withContentsOfURL:ofType:error: and
 makeDocumentWithContentsOfURL:ofType:error:

 @details  There is maybe a bug in macOS 10.14 Launch Services which this
 method works around.  After rebuilding the Launch Services database,
 later in the day I found that the super call in both
 makeDocumentForURL:withContentsOfURL:ofType:error: and
 makeDocumentWithContentsOfURL:ofType:error: were raising an exception
 exception.  (We call these the two "-makeDocument…" methods.)  The exception
 was because the 'url' and 'typeName' passed to this
 method by Cocoa during document opening were cross-wired.  Here is the
 debug session:

 (lldb) po url
 file:///Users/jk/Library/Application%20Support/BookMacster/Collections/Test.bmco/
 (lldb) po typeName
 com.sheepsystems.bookmacster.bookmarkshelf

 You see the user has requestd to open a current .bmco file, but the system
 has for some reason labelled it as a legacy "bookmarkshelf" type.  It will
 try to read data with the legacy Bkmslf class, which of course will not
 work.  Now, of course this could be explained by my having cross-wired the
 document extensions and types in my Info.plist, but I checked these and
 they are not cross-wired.

 To work around this issue, I dig into the Info.plist and look for the
 proper typeName based on the filename extension of the passed-in url.
 If found, I overwrite the passed-in typeName with the first (and only)
 element of LSItemContentTypes, lowercased, which is of course

 > com.sheepsystems.bookmacster.collection

 The reason I lowercase it is because the typeName passed to this method
 is lowercase.  Maybe the document types in my Info.plist should be all
 lowercase?

 Anyhow, lowercase or not, it fixes the problem.  It also proves that, in
 my Info.plist, the document extensions and types are *not* cross-wired.

 There is also a small chance that this bug is the causing an issue for
 that handful of users who find that, after updating my app, upon opening
 a document, they get "Processing…" forever, or in BkmkMgrs version 2.9.2
 or later, Error 257938, because\
 -openDocumentWithContentsOfURL:display:completionHandler: never returns.

 To use this method, override both of the -makeDocument… methods of
 NSDocumentController and at the beginning of your overrides, before invoking
 super, call this method like this:

 NSString* msg = [self fixLaunchServicesBugForUrl:url typeName_p:&typeName];
 if (msg) { NSLog(msg); }  // optional

 @param   url  The url passed to one of the two -makeDocument… methods

 @param   typeName_p  The address of the typeName passed to one of the two
 -makeDocument… methods

 @result  If no correction was needed to the typeName, returns nil.  Otherwise,
 returns a human-readable message explaining what was done, suitable for
 logging.
 */
- (NSString* _Nullable)fixLaunchServicesBugForUrl:(NSURL* _Nullable)url
                                       typeName_p:(NSString* _Nonnull * _Nullable)typeName_p;

@end

NS_ASSUME_NONNULL_END
