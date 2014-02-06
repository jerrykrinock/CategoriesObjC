#import "NSPersistentDocument+Pathify.h"
#import "NSDocumentController+DisambiguateForUTI.h"
#import "NSDocument+SyncModDate.h"
#import "NSBundle+MainApp.h"
#import "NSPersistentStoreCoordinator+RollbackJournaling.h"

NSString* const SSYDocumentDidSaveNotification = @"SSYDocumentDidSaveNotification" ;
NSString* const SSYDocumentDidSucceed = @"SSYDocumentDidSucceed" ;
NSString* const SSYDocumentSaveOperation = @"SSYDocumentSaveOperation" ;

NSString* const SSYPersistentDocumentPathifyErrorDomain = @"SSYPersistentDocumentPathifyErrorDomain" ;


@implementation NSPersistentDocument (Pathify)

- (BOOL)saveCopyToNewURL:(NSURL*)newURL
				   doSave:(BOOL)doSave
				deleteOld:(BOOL)deleteOld
				  error_p:(NSError**)error_p {
	BOOL ok = YES ;
	NSError* error_ = nil ;
	NSInteger errorCode = 0 ;
	
	// This section was added in BookMacster 1.9.9.
	if ([[self fileURL] isEqual:newURL]) {
		ok = NO ;
		error_ =  [NSError errorWithDomain:SSYPersistentDocumentPathifyErrorDomain
									  code:SSYPersistentDocumentPathifyErrorDestinationSameAsSource
								  userInfo:[NSDictionary dictionaryWithObject:@
											"You requested to rename this document to the same name it already has, and leave it in the same folder it is already in.\n\n"
											@"That means to do nothing.  We have therefore done nothing."
																	   forKey:NSLocalizedDescriptionKey]] ;
		goto end ;
	}
	
	// In case this comes from a dialog, make sure that newPath has the
	// proper filename extension.
	NSString* requiredExtension = [[NSDocumentController sharedDocumentController] defaultDocumentFilenameExtension] ;
	NSString* newPath = [newURL path] ;
	if (![[newPath pathExtension] isEqualToString:requiredExtension]) {
		newPath = [newPath stringByAppendingPathExtension:requiredExtension] ;
	}
	
	// Core Data needs a document file on disk to start with ...
	NSURL* oldURL = [self fileURL] ;
	if (!oldURL) {
		// This will execute for new, never-saved documents
		NSString* oldPath = NSTemporaryDirectory() ;
		NSString* bundleID = [[NSBundle mainAppBundle] bundleIdentifier] ;
		oldPath = [oldPath stringByAppendingPathComponent:bundleID] ;
		oldPath = [oldPath stringByAppendingString:@"_temp"] ;
		oldURL = [NSURL fileURLWithPath:oldPath] ;
		[self setFileURL:oldURL] ;
	}
	
	NSString* oldPath = [[self fileURL] path] ;
	
	// Core Data also needs a store ...
	if (ok) {
		NSManagedObjectContext* moc = [self managedObjectContext] ;
		NSPersistentStoreCoordinator* psc = [moc persistentStoreCoordinator] ;
		NSArray* stores = [psc persistentStores] ;
        NSDictionary* options = [NSPersistentStoreCoordinator dictionaryByAddingSqliteRollbackToDictionary:nil] ;
		if ([stores count] < 1) {
			// This will execute for new, never-saved documents
			NSPersistentStore* oldStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
															configuration:nil
																	  URL:oldURL
																  options:options
																	error:&error_] ;
			ok = (oldStore != nil) ;
		}
	}
	if (!ok) {
		errorCode = SSYPersistentDocumentPathifyErrorCouldNotOpenOldStore ;
		goto end ;
	}
	
	if (doSave) {
		// Note 0934857
		// Now we need to save the document.
		// The first thing I thought of is this:
		//   [self  saveToURL:oldURL
	    //             ofType:[self fileType
	    //   forSaveOperation:NSSaveOperation
	    //              error:&error_] ;
		// However, this is a higher-level operation which will
		// -setFileURL:, -synchronizeWindowTitleWithDocumentName, -setRepresentedFilename,
		// -setFileType:, -setFileModificationDate:
		//
		// The next thing I thought of is 
		// ok = [self writeSafelyToURL:oldURL
		//                      ofType:[self fileType]
        //            forSaveOperation:NSSaveOperation
        //                       error:&error_] ;
		// However, for BookMacster's BkmxDoc, its override of
		// writeSafelyToURL:ofType:forSaveOperation:error: posts an
		// SSYDocumentDidSaveNotification which will -doHousekeepingAfterSaveNotification,
		// which will check cloudability, which will find an error if
		// we are in the process of moving *into* the dropbox to correct the
		// cloudability error, since as you can see above we are still saving
		// to oldURL which will still be out of the Dropbox folder.  In other words,
		// the user will see a second error reiterating the error she just corrected
		// by initiating the saveAsMove: action.  Regarding the other methods mentioned
		// above, it seems that those are not necessary because they will be immediately
		// set to the correct, new values when we re-invoke 
		// saveToURL:ofType:forSaveOperation:error: below to save it to the
		// newURL.  ***Update***.  Since we no longer check cloudability
		// in -doHousekeepingAfterSaveNotification, this thing might work now.
		//
		// The next thing I tried was the same, except invoking super 
		// ok = [super writeSafelyToURL:oldURL
		//                       ofType:[self fileType]
        //             forSaveOperation:NSSaveOperation
        //                        error:&error_] ;
		// and this seemed to work OK until BookMacster 1.1 where alot of stuff was
		// changed in the data model.  Two problems arose.
		// Steps:
		// 1.  Create a New Bookmarkshelf with one client, Opera, importing
		// 2.  Save As Move.
		// Problem A: Before invoking writeSafelyToURL:ofType:forSaveOperation:error:,
		// if I fetch all managed objects of the Exporter_entity, I get one,
		// as expected.  But after this, repeat the fetch, and you get an empty
		// array.  But wait, if I then change an attribute of the "missing" object,
		// using the app's GUI, and re-run this logging method, the object reappears
		// in the new fetch result.  And it has the same pointer address and permanent
		// objectID as before.  And its -isFault and -isDeleted are both NO, both before
		// and after its dis/reappearance.  There are no user-discernable effects
		// of Problem A, but I didn't look very hard.
		// Problem B:  Core Data places a single Undo action on the stack:
		//   *** Begin logPeekUndo.  Top Undo Group: <GCUndoGroup 0x28e3060 actionName='(null)' 1 tasks at depth 0
		//   0x28e3060's Task 0/1: <GCConcreteUndoTask 0x17299820 0x17109300> invocn=<NSInvocation 0x28c5690 with targ=(null)
		//   selector is shown with 1 argument on each of the following lines:
		//      _noop:(arg 2/3)__NSArray0* count=0 >
		//   >*** End logPeekUndo
		//
	    // Well, the final thing I thought of was to use -[NSManagedObjectContext save:],
		// and that solved both Problem A and Problem B!
		ok = [[self managedObjectContext] save:&error_] ;

		if (!ok) {
			errorCode = SSYPersistentDocumentPathifyErrorCouldNotSaveManagedObjectContext ;
			goto end ;
		}
	}
	
	// If using the SQLite or other nonatomic store, need to move
	// old database so that Core Data can do "delta" business.
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
	if ([fileManager fileExistsAtPath:newPath]) {
		// Must remove existing item first or -moveItemAtPath:toPath:error: will fail.
		ok = [fileManager removeItemAtPath:newPath
									 error:&error_] ;
		if (!ok) {
			errorCode = SSYPersistentDocumentPathifyErrorCouldNotDeleteOldStore ;
			goto end ;
		}
	}		
	if (deleteOld) {
		ok = [fileManager moveItemAtPath:oldPath
								  toPath:newPath
								   error:&error_] ;
		if (!ok) {
			errorCode = SSYPersistentDocumentPathifyErrorCouldNotMoveStore ;
			goto end ;
		}
	}
	else {
#if (MAC_OS_X_VERSION_MAX_ALLOWED < 1060) 
		ok = [fileManager copyPath:oldPath
							toPath:newPath
						   handler:nil] ;
#else
		ok = [fileManager copyItemAtPath:oldPath
							toPath:newPath
							 error:&error_] ;
#endif
		if (!ok) {
			errorCode = SSYPersistentDocumentPathifyErrorCouldNotCopyStore ;
			NSDictionary* userInfo ;
			if (error_) {
				userInfo = [NSDictionary dictionaryWithObject:error_
													   forKey:NSUnderlyingErrorKey] ;
			}
			else {
				userInfo = nil ;
			}
			error_ = [NSError errorWithDomain:SSYPersistentDocumentPathifyErrorDomain
										 code:errorCode
									 userInfo:userInfo] ;
			
			goto end ;
		}
	}
	
	// Needed for NSDocument to use the new location for
	// future saves, window title bar, etc. ...
	[self setFileURL:newURL] ;
	
	// Added in BookMacster 1.6.6.  See -syncFileModificationDate for reason
	[self syncFileModificationDate] ;

	// Needed to avoid NSDocument displaying a sheet which tells the
	// user that the document has been moved, and ask do they really
	// want to save it in the new location, the next time they click
	// in the menu File > Save ...
	// TODO: So it would be nice to get a better solution to this problem
	// so we wouldn't have to save the document twice.  Note that for
	// a new BookMacster Bookmarkshelf, we actually save it three times
	// during creation.  The third time is when @"saveDocument" is 
	// invoked after @"expandAllContent" in the operation queue.
	// See -saveAndClearUndo.	
	ok = [self saveToURL:newURL
				  ofType:[self fileType]
		forSaveOperation:NSSaveOperation
				   error:&error_] ;
	
	if (ok) {
	}
	else {
		errorCode = SSYPersistentDocumentPathifyErrorCouldNotSaveStore ;
		goto end ;
	}
	
end:;
	if (error_p && error_) {
		if (errorCode > 0) {
			NSString* errorDescription = [NSString stringWithFormat:
										  @"Error in %s",
										  __PRETTY_FUNCTION__] ;
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  errorDescription, NSLocalizedDescriptionKey,
									  error_, NSUnderlyingErrorKey,
									  newPath, @"New Path",
									  oldURL, @"Old URL",
									  nil] ;
			*error_p = [NSError errorWithDomain:SSYPersistentDocumentPathifyErrorDomain
										   code:errorCode
									   userInfo:userInfo] ;
		}
		else {
			*error_p = error_ ;
		}
	}

	return ok ;
}

- (BOOL)saveMoveToNewUrl:(NSURL*)newUrl
				  error_p:(NSError**)error_p {
	return [self saveCopyToNewURL:newUrl
						   doSave:YES
						deleteOld:YES
						  error_p:error_p] ;
}

- (BOOL)copyToNewUrl:(NSURL*)newUrl
			 error_p:(NSError**)error_p {
	return [self saveCopyToNewURL:newUrl
						   doSave:NO
						deleteOld:NO
						  error_p:error_p] ;
}

- (void)saveMoveToNewUrl:(NSURL*)newUrl {
	NSError* error = nil  ;
	BOOL ok = [self saveMoveToNewUrl:newUrl
							 error_p:&error] ;
	if (!ok) {
		// Note: In a real application, you will have customized
		// error presentation using willPresentError: because
		// Apple's is so lame -- doesn't even make it possible
		// to recover the userInfo dictionary.&nbsp;  Either way,
		// the following will get us there:
		[self presentError:error] ;
	}		
}	

#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1060)
#define NEEDS_CALLBACK_FOR_SAVE_MOVE_PANEL_DID_END 1
#endif

- (void)saveAsMoveToDirectory:(NSString*)parentPath
					  message:(NSString*)message
			   doneInvocation:(NSInvocation*)doneInvocation {
	NSSavePanel* panel ;
	panel = [NSSavePanel savePanel] ;
	SEL selector ;
	
	if (!message) {
		selector = @selector(saveAsMoveMessage) ;
		if ([self respondsToSelector:selector]) {
			message = [self performSelector:selector] ;
		}
	}
	[panel setMessage:message] ;
	
	selector = @selector(saveAsMoveLabel) ;
	if ([self respondsToSelector:selector]) {
		[panel setNameFieldLabel:[self performSelector:selector]] ;
	}
	
	selector = @selector(saveAsMovePrompt) ;
	if ([self respondsToSelector:selector]) {
		[panel setPrompt:[self performSelector:selector]] ;
	}
	
	[panel setCanCreateDirectories:YES] ;
	// The following two lines were added as a bug fix in BookMacster 1.1
	[panel setAllowedFileTypes:[NSArray arrayWithObject:[[NSDocumentController sharedDocumentController] defaultDocumentFilenameExtension]]] ;
	[panel setAllowsOtherFileTypes:NO] ;  // Supposedly this is default, but I want to make sure this always works.
	
	NSWindow* window = nil ;
	NSArray* windowControllers = [self windowControllers] ;
	if ([windowControllers count] > 0) {
		window = [(NSWindowController*)[windowControllers objectAtIndex:0] window] ;
	}
#if NEEDS_CALLBACK_FOR_SAVE_MOVE_PANEL_DID_END
	NSDocumentController* dc = [NSDocumentController sharedDocumentController] ;
	selector = @selector(nextDefaultDocumentUrl) ;
	NSURL* suggestedURL = nil ;

	if ([dc respondsToSelector:selector]) {
		suggestedURL = [dc performSelector:selector] ;
	}
#pragma deploymate push "ignored-api-availability" // Skip it until next "pop"
	[panel beginSheetForDirectory:parentPath
							 file:[[suggestedURL path] lastPathComponent]
				   modalForWindow:window
					modalDelegate:self
				   didEndSelector:@selector(saveMovePanelDidEnd:returnCode:contextInfo:)
					  contextInfo:[doneInvocation retain]] ;
#pragma deploymate pop
	// doneInvocation will be released in -saveMovePanelDidEnd:returnCode:contextInfo:
#else
    [panel beginSheetModalForWindow:window
                  completionHandler:^(NSInteger returnCode) {
                      if (returnCode == NSFileHandlingPanelOKButton) {
                          NSURL* newUrl = [panel URL] ;
                          [self saveMoveToNewUrl:newUrl] ;
                      }
                      
                      [doneInvocation invoke] ;
                  }];
#endif
	// Note: Built-in behavior of NSSavePanel checks to see if the path chosen
	// by the user already exists, and if so runs the "Replace?" sheet over
	// this sheet.
}

#if NEEDS_CALLBACK_FOR_SAVE_MOVE_PANEL_DID_END
- (void)saveMovePanelDidEnd:(NSSavePanel *)sheet
				 returnCode:(NSInteger)returnCode
				contextInfo:(void*)contextInfo {
	NSInvocation* doneInvocation = (NSInvocation*)contextInfo ;
	// contextInfo was previously retained
	[doneInvocation autorelease] ;
    
	if (returnCode == NSFileHandlingPanelOKButton) {
		NSURL* newUrl = [sheet URL] ;
		[self saveMoveToNewUrl:newUrl] ;
	}
	
	[doneInvocation invoke] ;
}
#endif

- (IBAction)saveAsMove:(id)sender {
	[self saveAsMoveToDirectory:nil
						message:nil
				 doneInvocation:nil] ;
}

@end