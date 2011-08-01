#import <Cocoa/Cocoa.h>


/*!
 @brief    Provides support for finding helper tools in
 a bundle's Contents/Helpers/

 @details  You can add a Copy Files Build Phase in Xcode for putting things
 in Contents/Helpers by setting the Destination popup to 'Wrapper' and then
 below that giving path "Contents/Helpers".
 
 The reason why you'd want to put helper tools in
 Contents/Helpers is in
 
 http://www.cocoabuilder.com/archive/message/cocoa/2009/3/26/233141
 
 Most pertinently, 
 
 TO: cocoa-dev@lists.apple.com
 FROM : Jim Correia
 DATE : Thu Mar 26 00:52:10 2009
 
 On Mar 25, 2009, at 7:20 PM, Jerry Krinock wrote:
 
 > Use this code to build a Cocoa Command-Line tool and place
 > the product in Contents/MacOS of any application.  Then
 > doubleclick it.  Watch the log in the Terminal window and
 > un-hide and watch your dock.
  
 There are a couple of edge cases you will run into if you place  
 auxiliary executables into the MacOS folder an execute them from there.
 
 Besides the one you mention, you can (in certain situations) end up  
 with an incorrect entry in the LS database which will cause the wrong  
 executable to be launched when the user double clicks on your app in  
 the Finder.
 
 I recommend putting aux executables in
 
 .../Contents/Helpers/...
 
 as it avoids these issues. (And have filed an ER asking for this to  
 become an officially sanctioned location for both bundled and  
 unbundled helpers.)
*/
@interface NSBundle (HelperPaths)

/*
 @brief    Returns a path for a given tool name in the receiving bundle
 in directory Contents/Helpers/
*/
- (NSString*)pathForHelper:(NSString*)helperName ;

@end
