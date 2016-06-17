#import "NSDocumentController+MoreRecents.h"
#import "NSURL+FileDisplayName.h"
#import "NSMenuItem+Font.h"

@implementation NSDocumentController (MoreRecents)

- (void)forgetRecentDocumentUrl:(NSURL*)url {
	if (url) {
		NSArray* recentDocumentURLs = [self recentDocumentURLs] ;
		[self clearRecentDocuments:self] ;
		// Because noteNewRecentDocumentURL: adds to the top
		// of the list, I need a reverse enumeration to avoid
		// reversing the order of the remaining recent documents
		NSEnumerator* e = [recentDocumentURLs reverseObjectEnumerator] ;
		for (NSURL* aUrl in e) {
			if (![aUrl isEqual:url]) {
				[self noteNewRecentDocumentURL:aUrl] ;
			}
		}
	}
}

- (NSArray*)recentDocumentDisplayNames {
	return [[self recentDocumentURLs] valueForKey:@"fileDisplayName"] ;
}

- (NSMenu*)recentDocumentsSubmenuWithTarget:(id)target
									 action:(SEL)action
								   fontSize:(CGFloat)fontSize {
	NSMenu* submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"reecentDox", nil)] ;
	for (NSURL* url in [self recentDocumentURLs]) {
		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[url fileDisplayName]
													  action:action
											   keyEquivalent:@""] ;
		[item setFontColor:nil
					  size:fontSize] ;
		[item setTarget:target] ;
		[item setRepresentedObject:url] ;
		[submenu addItem:item] ;
		[item release] ;
	}
	
	return [submenu autorelease] ;
}

@end
