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
 began undo grp:  grpLvl: 0:1  state: Collecting:Collecting  chgCnt: 0:0
 Did change type Do.  changeCount: 0:1
 ended undo grp:  grpLvl: 1:0  state: Collecting:Collecting  chgCnt: 0:1
 
 CLICK "Undo"
 ended undo grp:  grpLvl: 0:0  state: Collecting:Collecting  chgCnt: 1:1
 22388: Set state to Undoing
 began undo grp:  grpLvl: 0:1  state: Undoing:Undoing  chgCnt: 1:1
 ended undo grp:  grpLvl: 1:0  state: Undoing:Undoing  chgCnt: 1:1
 23172: Set state back to Collecting
 Did change type Undo.  changeCount: 1:0
 // Note: The above is caused by NSUndoManagerDidUndoChangeNotification
 // being observed by -[NSDocument updateChangeCount:]
 
 CLICK "Redo"
 23741: Set state to Redoing
 began undo grp:  grpLvl: 0:1  state: Redoing:Redoing  chgCnt: 0:0
 ended undo grp:  grpLvl: 1:0  state: Redoing:Redoing  chgCnt: 0:0
 24166: Set State back to Collecting
 Did change type Redo.  changeCount: 0:1
 // Note: The above is caused by NSUndoManagerDidRedoChangeNotification
 // being observed by -[NSDocument updateChangeCount:]
 
 CLICK "Undo"
 ended undo grp:  grpLvl: 0:0  state: Collecting:Collecting  chgCnt: 1:1
 22388: Set state to Undoing
 began undo grp:  grpLvl: 0:1  state: Undoing:Undoing  chgCnt: 1:1
 ended undo grp:  grpLvl: 1:0  state: Undoing:Undoing  chgCnt: 1:1
 23172: Set state back to Collecting
 Did change type Undo.  changeCount: 1:0
 
*/

// The following nested compiler directives look a little redundant.  However,
// I follow the convention of always enabling debug code with "#if 1", so that
// I can always find all of them, for example when it's time to ship, by
// searching the project for "#if 1".
#if 0
#define GCUNDOMANAGER_DEBUG 1 
#warning Compiling with GCUndoManager+Debug Code

@interface GCUndoManager (SSYDebug)

- (void)logPeekUndo ;

@end

#endif 