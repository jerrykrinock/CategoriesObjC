#import "NSManagedObject+SSYCopying.h"
#import "NSObject+RecklessPerformSelector.h"


@implementation NSManagedObject (SSYCopying)

- (NSManagedObject*)shallowCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc {
    NSEntityDescription* entity = self.entity ;
    NSManagedObject* newObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name
                                                               inManagedObjectContext:targetMoc] ;
    /* Another up-vote for Marcus Zarra:
     http://stackoverflow.com/questions/2998613/how-do-i-copy-or-move-an-nsmanagedobject-from-one-context-to-another
     */
    NSDictionary* attributeDic = [self dictionaryWithValuesForKeys:[[entity attributesByName] allKeys]] ;
    [newObject setValuesForKeysWithDictionary:attributeDic] ;
    
    return newObject ;
}

- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                           doNotEnterRelationships:(NSSet <NSRelationshipDescription*> *)doNotEnterRelationships {
    NSEntityDescription* entity = self.entity ;
    NSManagedObject* __block newObject = nil ;
    [targetMoc performBlockAndWait:^(void) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name
                                                  inManagedObjectContext:targetMoc] ;
        NSDictionary* __block attributeDic = nil ;
        [[self managedObjectContext] performBlockAndWait:^(void) {
            attributeDic = [self dictionaryWithValuesForKeys:[[entity attributesByName] allKeys]] ;
#if !__has_feature(objc_arc)
            [attributeDic retain];
#endif
        }] ;
        [newObject setValuesForKeysWithDictionary:attributeDic] ;
#if !__has_feature(objc_arc)
        [attributeDic release];
        [newObject retain];
#endif
    }] ;

    NSMutableSet<NSRelationshipDescription*>* alwaysDoNotEnterRelationships = [NSMutableSet new];
    for (NSRelationshipDescription* relationship in doNotEnterRelationships) {
        [alwaysDoNotEnterRelationships addObject:relationship];
        NSRelationshipDescription* inverseRelationship = [relationship inverseRelationship] ;
        NSAssert(
                 (inverseRelationship != nil),
                 @"[1] No inverse relationship in %@ from %@ in %@",
                 relationship.destinationEntity.name,
                 relationship.name,
                 self.className);
        [alwaysDoNotEnterRelationships addObject:inverseRelationship];
    }

    NSSet <NSString*> * doNotEnterKeys = [doNotEnterRelationships valueForKey:@"name"]  ;
    NSDictionary* relationships = [entity relationshipsByName] ;
    for (NSString* key in relationships) {
        if (![doNotEnterKeys member:key]) {
            NSRelationshipDescription* relationship = [relationships objectForKey:key] ;
            NSRelationshipDescription* inverseRelationship = [relationship inverseRelationship] ;
            NSAssert(
                     (inverseRelationship != nil),
                     @"[2] No inverse relationship in %@ from %@ in %@",
                     relationship.destinationEntity.name,
                     relationship.name,
                     self.className) ;
            NSString* inverseKey = inverseRelationship.name ;
            // Note: Property .toMany requires OS X 10.10 or later
            if (relationship.toMany) {
                // To-Many Relationship
                NSObject <NSFastEnumeration> __block * oldCollection = nil ;
                [[self managedObjectContext] performBlockAndWait:^(void) {
                    oldCollection = [self valueForKey:key] ;
#if !__has_feature(objc_arc)
                    [oldCollection retain];
#endif
                }] ;

                /* The following assumes that you have used mogenerator
                 or equivalent to define add<Key>Object: setters for all of
                 your managed object's to-many relationships. */
                NSString* addObjectSetterName = [[NSString alloc] initWithFormat:
                                                 @"add%@Object:",
                                                 [key capitalizedString]] ;
                SEL addObjectSelector = NSSelectorFromString(addObjectSetterName) ;
#if !__has_feature(objc_arc)
                [addObjectSetterName release];
#endif
                [[self managedObjectContext] performBlockAndWait:^(void) {
                    for (NSManagedObject* oldChild in oldCollection) {
                        NSMutableSet<NSRelationshipDescription*>* doNotEnterInverseRelationships = [alwaysDoNotEnterRelationships mutableCopy];
                        [doNotEnterInverseRelationships addObject:inverseRelationship];
                        [doNotEnterInverseRelationships removeObject:relationship];
                        NSManagedObject* newChild = [oldChild deepCopyInManagedObjectContext:targetMoc
                                                                     doNotEnterRelationships:doNotEnterInverseRelationships] ;

                        #if !__has_feature(objc_arc)
                            [doNotEnterInverseRelationships release];
                        #endif
                        // Wire up relationship, and its inverse relationship.
                        [targetMoc performBlockAndWait:^(void) {
                            [newObject recklessPerformVoidSelector:addObjectSelector
                                                            object:newChild] ;
                            [newChild setValue:newObject
                                        forKey:inverseKey] ;
                        }] ;
                    }
                }] ;
#if !__has_feature(objc_arc)
                [oldCollection release];
#endif
            }
            else {
                // To-One Relationship
                NSManagedObject* __block oldChild = nil ;
                [[self managedObjectContext] performBlockAndWait:^(void) {
                    oldChild = [self valueForKey:key] ;
                }] ;
                NSManagedObject* newChild = [oldChild deepCopyInManagedObjectContext:targetMoc
                                                             doNotEnterRelationships:alwaysDoNotEnterRelationships] ;
                [targetMoc performBlockAndWait:^(void) {
                    // Wire up relationship, and its inverse relationship.
                    [newObject setValue:newChild
                                 forKey:key] ;
                    [newChild setValue:newObject
                                forKey:inverseKey] ;
                }] ;
            }
        }
    }
#if !__has_feature(objc_arc)
    [newObject autorelease];
    [alwaysDoNotEnterRelationships release];
#endif
    
    return newObject ;
}

- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                       doNotEnterRelationshipNames:(NSSet*)relationshipNames {
    NSDictionary* relationships = [self.entity relationshipsByName] ;
    NSMutableSet <NSRelationshipDescription*> * doNotEnterRelationships = [NSMutableSet new] ;
    for (NSString* name in relationshipNames) {
        NSRelationshipDescription* relationship = [relationships objectForKey:name] ;
        if (relationship) {
            [doNotEnterRelationships addObject:relationship] ;
        }
    }

    NSSet* doNotEnterRelationshipsCopy = [doNotEnterRelationships copy];
    NSManagedObject* answer = [self deepCopyInManagedObjectContext:targetMoc
                                           doNotEnterRelationships:doNotEnterRelationshipsCopy] ;
#if !__has_feature(objc_arc)
    [doNotEnterRelationships release];
    [doNotEnterRelationshipsCopy release];
#endif

    return answer;
}

- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc
                        doNotEnterRelationshipName:(NSString*)relationshipName {
    return [self deepCopyInManagedObjectContext:targetMoc
                    doNotEnterRelationshipNames:[NSSet setWithObject:relationshipName]] ;
}

- (NSManagedObject*)deepCopyInManagedObjectContext:(NSManagedObjectContext*)targetMoc {
    return [self deepCopyInManagedObjectContext:targetMoc
                    doNotEnterRelationshipNames:nil] ;
}

- (void)deepDescriptionIntoString:(NSMutableString*)string
           fromParentRelationship:(NSRelationshipDescription*)fromParentRelationship {
    NSEntityDescription* entity = self.entity ;
    NSDictionary* attributeDic = [self dictionaryWithValuesForKeys:[[entity attributesByName] allKeys]] ;
    [string appendFormat:
     @"Attributes for %@:\n%@",
     entity.name,
     attributeDic] ;
    NSRelationshipDescription* fromParentInverseRelationship =[fromParentRelationship inverseRelationship] ;
    NSString* fromParentInverseKey = fromParentInverseRelationship.name ;
    NSDictionary* relationships = [entity relationshipsByName] ;
    for (NSString* key in relationships) {
        if (![key isEqualToString:fromParentInverseKey]) {
            NSRelationshipDescription* relationship = [relationships objectForKey:key] ;
            NSAssert(
                     ([relationship inverseRelationship] != nil),
                     @"No inverse relationship in %@ from %@ in %@",
                     relationship.destinationEntity.name,
                     relationship.name,\
                     self.className) ;
            // Note: Property .toMany requires macOS 10.10 or later
            if (relationship.toMany) {
                // To-Many Relationship
                NSObject <NSFastEnumeration> * oldCollection = [self valueForKey:key] ;
                NSInteger i = 0 ;
                for (NSManagedObject* oldChild in oldCollection) {
                    [string appendFormat:
                     @"Digging into %@ index %ld...",
                     relationship.name,
                     (long)i] ;
                    [oldChild deepDescriptionIntoString:string
                                 fromParentRelationship:relationship] ;
                    i++ ;
                }
            }
            else {
                // To-One Relationship
                NSManagedObject* oldChild = [self valueForKey:key] ;
                [oldChild deepDescriptionIntoString:string
                             fromParentRelationship:relationship] ;
            }
        }
    }
}

- (NSString*)deepDescriptionIgnoringRelationshipWithName:(NSString*)ignoredName {
    NSMutableString* dd = [[NSMutableString alloc] initWithFormat:
                           @"***********************\nDeep Description of %@ %p in moc named %@\n",
                           [self className],
                           (__bridge void*)self,
                           self.managedObjectContext.name] ;

    NSEntityDescription* entity = self.entity ;
    NSRelationshipDescription* fromParentRelationshipToIgnore = nil ;
    if (ignoredName) {
        NSDictionary* relationships = [entity relationshipsByName] ;
        for (NSString* key in relationships) {
            if ([key isEqualToString:ignoredName]) {
                NSRelationshipDescription* fromChildRelationship = [relationships objectForKey:key] ;
                fromParentRelationshipToIgnore = [fromChildRelationship inverseRelationship] ;
            }
        }
    }
    
    [self deepDescriptionIntoString:dd
             fromParentRelationship:fromParentRelationshipToIgnore] ;
    NSString* answer = [dd copy];
#if !__has_feature(objc_arc)
    [dd release];
    [answer autorelease];
#endif
    return answer;
}

@end
