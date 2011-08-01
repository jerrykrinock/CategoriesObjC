#import <Cocoa/Cocoa.h>

@interface NSHelpManager (HelpForHelp)
/* Provides a workaround for Apple Bug 4212853, duplicate 3946514,
which is that help anchors will not be scrolled to on a newly-
opened page which has a link to an external CSS document.  This
bug is apparently in Help Viewer because it is seen whether
you use Cocoa, Carbon or AppleScript direct from Script Editor.
The first two methods are replacments for -openHelpAnchor:inBook:
and the last one is a little bonus.  */

+ (void)openAnchor:(NSString*)anchor 
 neighboringAnchor:(NSString*)neighboringAnchor ;
	// neighboringAnchor is any other anchor on same page as anchor

+ (void)openAnchor:(NSString*)anchor ;
	// If anchor is simply an anchor, may or may not scroll depending
	// on whether or not Apple bug 4212853 applies
	// If anchor is of the form @"anchor|neighboringAnchor",
	// that is two anchors separated by a pipe, then it invokes
	// openAnchor:neighboringAnchor and tries the bug workaround.
+ (void)openPage:(NSString*)page ;
	// Cocoa wrapper for function only available in Carbon.

@end

