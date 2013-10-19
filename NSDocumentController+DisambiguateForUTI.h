#import <Cocoa/Cocoa.h>


/*!
 @brief    This category augments NSDocumentController
 methods for getting and converting among (1) the old
 "document type", which was the string in the Info.plist, (2)
 new "document type", which is the UTI, and (3) the "file type",
 which is the filename extension.
 
 @details  This category requires that the host application has
 defined a UTI for each of its document types.
 
 Those "three document type attributes" are:
 Display Name, UTI, and Filename Extension.
 
 We define "Display Name" as the "Kind" of the document shown
 when inspecting a document in the Finder&nbsp;  It is shown
 in Xcode's Target Inspector > Properties as "Name".&nbsp; It is also shown in the application's
 Info.plist as CFBundleTypeName.&nbsp;  A given document type has
 only one Display Name.&nbsp;  Note that invoking the Apple method
 [[NSDocumentController sharedDocumentController] displayNameForType:[[NSDocumentController sharedDocumentController] defaultType]]
 returns the "Display Name" as we have defined it if a document's
 UTI has not been defined, but returns nil if UTI has been
 defined.&nbsp;  I'm not sure if this is a bug or if their
 purposes are just way over my head.
 
 We define "UTI" as the "UTI" shown in Xcode's Target Inspector >
 .&nbsp; "UTI" does not seem to be visible in Finder.&nbsp; 
 UTI is also shown in the application's Info.plist as an element
 of the array LSItemContentTypes.&nbsp;
 Apparently, a given document type may have more than one Filename
 Extension.
 
 We define "Filename Extension" as the "Extension" of the document shown
 when inspecting a document in the Finder&nbsp;  It is shown in Xcode's
 Target Inspector > Properties as "Extension".&nbsp;  It is also shown
 in the application's Info.plist as an element of the array
 CFBundleTypeExtensions.&nbsp;  Apparently, a given document type may
 have more than one Filename Extension.  The "Filename Extension"
 is also called the "file type" in Apple documentation.
 */
@interface NSDocumentController (DisambiguateForUTI)

/*!
 @brief    Returns the first filename extension for the application's
 document type with a given UTI.
*/
- (NSString*)filenameExtensionForDocumentUTI:(NSString*)uti ;

/*!
 @brief    Returns the "Display Name" of the application's document type
 with a given UTI.
*/
- (NSString*)displayNameForDocumentUTI:(NSString*)uti ;

/*!
 @brief    Returns the first UTI for the application's default
 document type.
*/
- (NSString*)defaultDocumentUTI ;

/*!
 @brief    Returns the Display Name for the application's default
 document type.
 */
- (NSString*)defaultDocumentDisplayName ;

/*!
 @brief    Returns the first filename extension for the application's
 default document type.
 */
- (NSString*)defaultDocumentFilenameExtension ;

- (Class)defaultDocumentClass ;

/*
 @brief    Returns the value of CFBundleTypeIconFile given in Info.plist for the
 application's default document type
 */
- (NSString*)defaultDocumentIconName ;

- (NSImage*)defaultDocumentImage ;

@end
