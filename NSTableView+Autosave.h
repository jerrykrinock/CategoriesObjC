#import <Cocoa/Cocoa.h>


/*!
 @brief    Alternative if you don't like the way that NSTableView's
 setAutosaveTableColumns:YES and setAutosaveName: make a mess of your
 app's preferences file.  Has methods for encoding and decoding
 the state of an NSTableView into a dictionary.

 @details  This is the equivalent of NSWindow methods
 -stringWithSavedFrame and -setFrameFromString: which
 NSTableView does not provide.
 
 At this time, the autosave state includes only:
 *  width
 *  userDefinedAttribute
 Other attributes like column ordering, sort ordering, and identification
 of hidden columns could be added to the dictionary.
*/
@interface NSTableView (Autosave) 

/*!
 @brief    Returns a dictionary encoding the current autosave state
 of the receiver.
*/
- (NSDictionary*)currentState ;

/*!
 @brief    Restores the state of the receiver as decoded from a
 given autosave state.
 
 @details  Subclasses typically override to set a default
 state if the autosaveState parameter is nil.
*/
- (void)restoreFromAutosaveState:(NSDictionary*)autosaveState ;

@end
