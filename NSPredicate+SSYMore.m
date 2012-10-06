#import "NSPredicate+SSYMore.h"

@implementation NSPredicate (SSYMore)

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

+ (NSPredicate*)orPredicateWithKeyPath:(NSString*)keyPath
								values:(NSSet*)values {
	NSMutableArray* subpredicates = [[NSMutableArray alloc] init] ;	
	NSExpression* lhs = [NSExpression expressionForKeyPath:keyPath] ;
	for (id value in values) {
		NSExpression* rhs = [NSExpression expressionForConstantValue:value] ;
		NSPredicate* subpredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs
																	   rightExpression:rhs
																			  modifier:NSDirectPredicateModifier
																				  type:NSEqualToPredicateOperatorType
																			   options:0] ;
		[subpredicates addObject:subpredicate] ;		
	}
	
	NSPredicate* predicate = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates] ;
	[subpredicates release] ;
	
	return predicate ;
}

@end