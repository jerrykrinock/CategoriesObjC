

@implementation NSArray (Select1)

- (id)select1 {
	id answer ;
	if ([self count] == 1) {
		answer = [self objectAtIndex:0] ;
	}
	else if ([self count] == 0) {
		answer = NSNoSelectionMarker ;
	}
	else {
		answer = NSMultipleValuesMarker ;
	}
	
	return answer ;
}

@end
