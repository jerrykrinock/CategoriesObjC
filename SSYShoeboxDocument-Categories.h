#import "BkmxDoc.h"


/*!
 @details  This function could also be implemented more directly as a menu
 delegate.  See SSYFileMenuPruner.
 */
@interface NSMenu (SSYShoeboxDocument)

/*
 @brief    Removes the "Open", "Open Recent", "Duplicate", and "Rename"
 menu items from the receiver
 
 @details  To use this method, make some object a menu delegate of the target
 menu (usually your File menu in the main menu), and then within your
 implementation of -menuNeedsUpdate:, send this message to the menu which is
 passed in.
 
 The reason why you can't just *not* put, for example, "Open" into your menu
 if you don't want it is because Cocoa will not replace the "Revert" menu item
 with or add the desired "Revert To…" menu item in a document with Lion Auto
 Save enabled unless the menu has "Open" and "Close" items, or, more exactly,
 menu items with actions -openDocument: and -performClose:.  Maybe Apple
 wanted some extra insurance that they were modifying the correct menu?
 */
- (void)removeNonShoeboxMultiDocItems ;

@end



 /*
 @brief     A category of NSDocument which, when added to a document-based
  Cocoa application, will remove items which are not sensible for a shoebox
  document from the Auto Save / Versions menu which appears when the user clicks
  the disclosure triangle in the title bar of a document, in macOS 10.8 and
  earlier
 
  @details   The Auto Save / Versions menu which appears when the user clicks
  the disclosure triangle in the title bar of a document has these items…
  
  Rename…
  Move To…
  Duplicate
  Lock
  Revert to…
  Last Opened
  Browse All Versions…
  
  The first 4 items do not make sense for a shoebox app.  Because Cocoa 
  apparently assigns the document to be the menu delegate of this menu,
  this override can and does eliminate those four non-sensible items.
  
  It is admittedly somewhat fragile because I had to reverse-engineer which
  menu items to delete based on their actions (selectors).  These selectors
  are Apple implementation detail.  The fact that the document is the delegate
  for this menu, and thus the fact that -menuNeedsUpdate: even gets invoked,
  is probably an implementation detail also.
  
  And, in fact, they did break it, in OS X 10.9, when the menu up there
  was replaced with a popover.  Fortunately, they made it easier, because the
  popover contains *only* controls which are not applicable to shoebox
  documents:
  
  • A text field to rename
  • A token field to add tags
  • A control to "move" the document
  • A "Lock" checkbox.
  
  So what you want to do is simply disable the showing of this popover.  After
  a little poking around, I found it is easy to do that, in -awakeFromNib
  of the window controller.  Just add this line of code:
  
  [[[self window] standardWindowButton:NSWindowDocumentVersionsButton] setHidden:YES] ;
  
  (The symbol name NSWindowDocumentVersionsButton is apparently a holdover from
  the prior usage.)

  For apps targetting 10.9 or later, that's all you need to do.  You do NOT
  need this category.
  
  Note that the menu may not appear in versions of macOS later than
  macOS 10.8.  Therefore, this override may not be necessary in the future.
  It is never invoked.
 */
@interface NSDocument (SSYShoeboxDocument)

/*
 @brief    Override of undeclared NSDocument method which removes menu items
 which are not sensible for a shoebox document from the Auto Save / Versions
 menu which appears when the user clicks the disclosure triangle in the title
 bar of a document in macOS 10.8 and earlier.

 @details  Because NSDocument is not declared as conforming to NSMenuDelegate,
 invoking [super menuNeedsUpdate:menu] in as we do in our override causes a
 compiler warning.  We assume that Cocoa would not have sent us -menuNeedsUpdate
 if NSDocument  did not respond to it, and in a document supporting Lion Auto
 Save, in fact, it does.  This declaration prevents that compiler warning.
 */
- (void)menuNeedsUpdate:(NSMenu*)menu ;

@end

