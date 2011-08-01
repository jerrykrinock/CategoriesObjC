
@implementation NSCompoundPredicate (SSYMore)

+ (NSPredicate*)andPredicateWithDictionary:(NSDictionary*)dictionary {
	
	NSMutableArray* subpredicates = [NSMutableArray array] ;
	for (NSString* key in dictionary) {		
		NSExpression* lhs = [NSExpression expressionForKeyPath:key] ;
		NSExpression* rhs = [NSExpression expressionForConstantValue:[dictionary valueForKey:key]] ;
		NSPredicate* subpredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs
																	rightExpression:rhs
																		   modifier:NSDirectPredicateModifier
																			   type:NSEqualToPredicateOperatorType
																			options:0] ;
		[subpredicates addObject:subpredicate] ;
	}
	
	NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates] ;
	
	return predicate ;
}

@end