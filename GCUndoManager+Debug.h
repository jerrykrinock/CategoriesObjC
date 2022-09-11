#import <Cocoa/Cocoa.h>
#import "GCUndoManager.h"

/*!
 With this file compiled as part of your project which uses
 GCUndoManager as its undo manager(s), you can see if and when
 your app is sending the correct messages for undo and change
 management.
 
 Each line in the console log shows if an undo group was begun or
 ended, and the old and new values of the three important Undo
 Manager states, in this form
 <began|ended>  {<stateName> <oldStateValue>:<newStateValue>, …}

 For example, here are the messages logged when running the
 GCUndoManagerTestbed app through a simple do-undo-redo-undo cycle:
 
 APPLICATION LAUNCHED:
 Replaced -updateChangeCount in NSDocument for debugging.
 Replaced -beginUndoGrouping and -endUndoGrouping in GCUndoManager for debugging.
 
 EDIT SOMETHING UNDOABLE:
 began undo grp:  grpLvl: 0:1  state: Collecting:Collecting
 Did change type Do.
 ended undo grp:  grpLvl: 1:0  state: Collecting:Collecting
 
 CLICK "Undo"
 ended undo grp:  grpLvl: 0:0  state: Collecting:Collecting
 22388: Set state to Undoing
 began undo grp:  grpLvl: 0:1  state: Undoing:Undoing
 ended undo grp:  grpLvl: 1:0  state: Undoing:Undoing
 23172: Set state back to Collecting
 Did change type Undo.
 // Note: The above is caused by NSUndoManagerDidUndoChangeNotification
 // being observed by -[NSDocument updateChangeCount:]
 
 CLICK "Redo"
 23741: Set state to Redoing
 began undo grp:  grpLvl: 0:1  state: Redoing:Redoing
 ended undo grp:  grpLvl: 1:0  state: Redoing:Redoing
 24166: Set State back to Collecting
 Did change type Redo.
 // Note: The above is caused by NSUndoManagerDidRedoChangeNotification
 // being observed by -[NSDocument updateChangeCount:]
 
 CLICK "Undo"
 ended undo grp:  grpLvl: 0:0  state: Collecting:Collecting
 22388: Set state to Undoing
 began undo grp:  grpLvl: 0:1  state: Undoing:Undoing
 ended undo grp:  grpLvl: 1:0  state: Undoing:Undoing
 23172: Set state back to Collecting
 Did change type Undo.
 
*/

// The following nested compiler directives look a little redundant.  However,
// I follow the convention of always enabling debug code with "#if 11", so that
// I can always find all of them, for example when it's time to ship, by
// searching the project for "#if 11".
#if 0
#define GCUNDOMANAGER_DEBUG 1 
#warning Compiling with GCUndoManager+Debug Code

@interface GCUndoManager (SSYDebug)

- (void)logPeekUndo ;

@end

#endif 
