#import "NSMigrationManager+10_5_BugPatch.h"
#import <objc/runtime.h>

@interface NSMigrationManager ()

- (NSArray*)destinationInstancesForSourceRelationshipNamed:(NSString*)srcRelationshipName
                                           sourceInstances:(id)source ;

@end

@implementation NSMigrationManager (_10_5_BugPatch)

+ (void)addRelationshipMigrationMethodIfMissing {
    SEL correctMethodSignature = @selector(destinationInstancesForSourceRelationshipNamed:sourceInstances:);
    Class migrationManagerClass = [NSMigrationManager class];
	
    if (NULL == class_getInstanceMethod(migrationManagerClass, correctMethodSignature)) {
        // Mac OS version is < 10.6.  Patch needed.
		Method m = class_getInstanceMethod(
										   migrationManagerClass,
										   @selector(workaround_destinationInstancesForSourceRelationshipNamed:sourceInstances:)
										   ) ;
        class_addMethod(
						migrationManagerClass,
						correctMethodSignature,
						method_getImplementation(m),
						method_getTypeEncoding(m)
						) ;
    }
}

+ (void)load {
	[self addRelationshipMigrationMethodIfMissing] ;
}

- (NSArray *)workaround_destinationInstancesForSourceRelationshipNamed:(NSString*)srcRelationshipName
													   sourceInstances:(id)source {
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSEntityMapping *eMapping = [self currentEntityMapping];
    NSEntityDescription* srcEntityInSrcModel = [self sourceEntityForEntityMapping:eMapping];
    NSEntityDescription* srcEntityInDstModel = [self destinationEntityForEntityMapping:eMapping];
    
    /* Source will be an NSManagedObject for a to-one relationship */
    NSArray *sourceInstances = ([source isKindOfClass:
								 [NSManagedObject class]]) ? [NSArray arrayWithObject: source] : source;
    
    /* Validate source relationship name */
    NSRelationshipDescription *relationshipInSrcModel = nil;    
    if (nil != srcRelationshipName) {
        relationshipInSrcModel = [[srcEntityInSrcModel relationshipsByName] objectForKey:srcRelationshipName];
    } else {
        NSString *reason = [[NSString alloc] initWithFormat:
							@"Property mapping in %@ missing required source relationship name argument to destinationInstancesForSourceRelationshipNamed:sourceInstances:",
							[eMapping name]];
        [pool drain];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
									   reason:[reason autorelease] userInfo: nil];
    }
    if (!relationshipInSrcModel) {
        NSString *reason = [[NSString alloc] initWithFormat:
							@"Can't find relationship for name (%@) for entity (%@) in source model.",
							srcRelationshipName, [srcEntityInSrcModel name]];
        [pool drain];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
									   reason:[reason autorelease] userInfo: nil];
    }
    
    /* Try to determine the destination relationship name by looking up the property mapping */
    NSString *dstRelationshipName = nil;
    for (NSPropertyMapping *pMapping in [eMapping relationshipMappings]) {
        NSExpression *expression = [pMapping valueExpression];
        if (([expression expressionType]==NSFunctionExpressionType) &&
			[[expression function] isEqualToString:@"destinationInstancesForSourceRelationshipNamed:sourceInstances:"]) {
            NSArray *arguments = [expression arguments];
            if ([arguments count] == 2) {
                id arg = [arguments objectAtIndex:0];
                if ([arg isKindOfClass:[NSExpression class]] &&
                    ([arg expressionType] == NSConstantValueExpressionType) &&
                    [[(NSExpression *)arg constantValue] isEqual:srcRelationshipName]) {
                    if (dstRelationshipName) {
                        NSString *reason = [[NSString alloc] initWithFormat:
											@"More than one property mapping (%@, %@) in %@ calls destinationInstancesForSourceRelationshipNamed:sourceInstances: with the same source relationship name %@, can't determine the correct destination relationship",
											dstRelationshipName, [pMapping name], [eMapping name], srcRelationshipName];
                        [pool drain];
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[reason autorelease] userInfo: nil];
                    }
                    dstRelationshipName = [pMapping name];
                }
            }
        }
    }
    
    /* Lookup the destination relationship */
    NSRelationshipDescription *relationshipInDstModel = nil;
    if (nil != dstRelationshipName) {
        relationshipInDstModel = [[srcEntityInDstModel relationshipsByName] objectForKey:dstRelationshipName];
    } else {
        [pool drain];
        return nil;
    }
    if (!relationshipInDstModel) {
        NSString *reason = [[NSString alloc] initWithFormat: @"Can't find relationship for name (%@) for entity (%@) in destination model.", dstRelationshipName, [srcEntityInDstModel name]];
        [pool drain];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[reason autorelease] userInfo: nil];
    }
    
    NSEntityDescription* dstEntityInSrcModel = [relationshipInSrcModel destinationEntity];
    NSEntityDescription* dstEntityInDstModel = [relationshipInDstModel destinationEntity];
    
    /* Lookup entity mappings for relationship destination subentities */
    NSMutableArray* mappings = [NSMutableArray array];
    for (NSEntityMapping* m in [[self mappingModel] entityMappings]) {
        if (([[self sourceEntityForEntityMapping:m] isKindOfEntity:dstEntityInSrcModel]) && 
            ([[self destinationEntityForEntityMapping:m] isKindOfEntity:dstEntityInDstModel])) {
            [mappings addObject:m];
        }
    }
	
    /* Find the destination instance for each source instance */
    NSMutableArray* results = [[NSMutableArray alloc] initWithCapacity:[sourceInstances count]];
    for (NSManagedObject* mo in sourceInstances) {
        NSManagedObject* peer = nil;
        for (NSEntityMapping* m in mappings) {
            // for each dest find peer in destination context by iterating through all relevant entity mappings
            NSArray* si = [[NSArray alloc] initWithObjects:mo,nil];
            NSArray* dests = [self destinationInstancesForEntityMappingNamed:[m name] sourceInstances:si];
            [si release];
            
            if (([dests count] > 1) || (([dests count] == 1) && (nil != peer))) {
                NSString *reason = [[NSString alloc] initWithFormat:
									@"More than one destination instance found for source instance of type (%@) for relationship mapping (%@).",
									[[mo entity] name], dstRelationshipName];
                [results release];
                [pool drain];
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[reason autorelease] userInfo: nil];
            }
            if ([dests count] == 1) {
                peer = [dests objectAtIndex:0];
                [results addObject:peer];
            }
        }
    }
	
    [pool drain];
    return [results autorelease];
}

@end