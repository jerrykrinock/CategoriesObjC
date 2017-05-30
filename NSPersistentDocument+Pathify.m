#import "NSPersistentDocument+Pathify.h"
#import "NSDocumentController+DisambiguateForUTI.h"
#import "NSDocument+SyncModDate.h"
#import "NSBundle+MainApp.h"
#import "NSPersistentStoreCoordinator+PatchRollback.h"

NSString* const SSYDocumentDidSaveNotification = @"SSYDocumentDidSaveNotification" ;
NSString* const SSYDocumentDidSucceed = @"SSYDocumentDidSucceed" ;
NSString* const SSYDocumentSaveOperation = @"SSYDocumentSaveOperation" ;

NSString* const SSYPersistentDocumentPathifyErrorDomain = @"SSYPersistentDocumentPathifyErrorDomain" ;


@implementation NSPersistentDocument (Pathify)

- (BOOL)saveCopyToNewURL:(NSURL*)newURL
                 error_p:(NSError**)error_p {
    BOOL ok = YES;
    NSError* error = nil;
    NSPersistentStoreCoordinator* psc = self.managedObjectContext.persistentStoreCoordinator;
    NSPersistentStore* oldStore = [[psc persistentStores] firstObject];
    [psc migratePersistentStore:oldStore
                          toURL:newURL
                        options:[NSPersistentStoreCoordinator dictionaryByAddingSqliteRollbackToDictionary:nil]
                       withType:NSSQLiteStoreType
                          error:&error];

end:;
    if (error) {
        ok = NO;
        if (error_p) {
            *error_p = error ;
        }
    }

	return ok ;
}

- (BOOL)saveMoveToNewUrl:(NSURL*)newUrl
				  error_p:(NSError**)error_p {
	return [self saveCopyToNewURL:newUrl
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
