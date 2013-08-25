#import "NSTableView+Autosave.h"
#import "NSTableView+MoreSizing.h"
#import "StarkTableColumn.h"

NSString* const constKeyWidths = @"widths" ;
NSString* const constKeyUserDefinedAttributes = @"userDefinedAttributes" ;


@implementation NSTableView (Autosave)

- (NSDictionary*)currentState {
	NSMutableDictionary* outerDic = [[NSMutableDictionary alloc] init] ;	
	NSMutableDictionary* innerDic ;

	// Encode widths
	innerDic = [[NSMutableDictionary alloc] init] ;
	for (NSTableColumn* column in [self tableColumns]) {
		if ([column identifier]) {
			[innerDic setObject:[NSNumber numberWithDouble:[column width]]
					 forKey:[column identifier]] ;
		}
	}
	if ([innerDic count] > 0) {
		[outerDic setObject:innerDic
				 forKey:constKeyWidths] ;
	}
	[innerDic release] ;
	
	// Encode user-defined keys
	innerDic = [[NSMutableDictionary alloc] init] ;
	for (NSTableColumn* column in [self tableColumns]) {
		if ([column respondsToSelector:@selector(userDefinedAttribute)]) {
			NSString* userDefinedAttribute = [column performSelector:@selector(userDefinedAttribute)] ;
			if (userDefinedAttribute) {
				[innerDic setObject:userDefinedAttribute
							 forKey:[column identifier]] ;
			}
		}
	}
	if ([innerDic count] > 0) {
		[outerDic setObject:innerDic
					 forKey:constKeyUserDefinedAttributes] ;
	}
	[innerDic release] ;
	
	// Summarize
	NSDictionary* answer = [outerDic copy] ;
	[outerDic release] ;
	
	return [answer autorelease] ;
}

- (void)restoreFromAutosaveState:(NSDictionary*)autosaveState {
	// Restore userDefinedAttributes
	NSDictionary* attributes = [autosaveState objectForKey:constKeyUserDefinedAttributes] ;
	for (NSString* identifier in attributes) {
		NSTableColumn* column = [self tableColumnWithIdentifier:identifier] ;
		if ([column respondsToSelector:@selector(setUserDefinedAttribute:)]) {
			[column performSelector:@selector(setUserDefinedAttribute:)
						 withObject:[attributes objectForKey:identifier]] ;
		}
	}	

	// Restore widths
	NSDictionary* widths = [autosaveState objectForKey:constKeyWidths] ;
	NSInteger i = 0 ;
	NSInteger nColumns = [self numberOfColumns] ;
	for (NSTableColumn* column in [self tableColumns]) {
		NSString* identifier = [column identifier] ;
		NSNumber* widthNumber = [widths objectForKey:identifier] ;
		CGFloat width = [widthNumber doubleValue] ;
		if (isnan(width)) {
			width = 80.0 ;
			NSLog(@"Warning 152-0842 Ignoring corrupt pref to set col width to nan") ;
		}

		if (i < nColumns - 1) {
			[column setWidth:width] ;
		}
		else {
			// The last column will be sized after this loop is done
		}
	}
	
	// This will make sure that there are no roundoff errors, etc.
	[self sizeLastColumnToFit] ;
}

@end