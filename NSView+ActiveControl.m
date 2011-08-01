

@implementation NSView (ActiveControl)

- (BOOL)isTheActiveControl {
	NSWindow* window_ = [self window] ;
	if (![window_ isMainWindow]) {
		return NO ;
	}
	if (![window_ isKeyWindow]) {
		return NO ;
	}
	if ([window_ firstResponder] != self) {
		return NO ;
	}
	
	return YES ;
}

@end
