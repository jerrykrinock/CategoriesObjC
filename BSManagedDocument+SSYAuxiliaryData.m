#import "BSManagedDocument+SSYAuxiliaryData.h"
#import "NSObject+DoNil.h"

NSString* auxiliaryDataFilename = @"auxiliaryData.plist";

@implementation BSManagedDocument (SSYAuxiliaryData)

+ (NSURL*)auxiliaryDataFileUrlForDocumentUrl:(NSURL*)url {
    url = [url URLByAppendingPathComponent:auxiliaryDataFilename];
    return url;
}

+ (NSString*)auxiliaryDataFilePathForDocumentPath:(NSString*)path {
    path = [path stringByAppendingPathComponent:auxiliaryDataFilename];
    return path;
}

+ (NSString *)documentPathForAuxiliaryDataFilePath:(NSString*)path
                                 documentExtension:(NSString*)extension {
    NSString* answer = nil;
    if ([path.lastPathComponent isEqualToString:auxiliaryDataFilename]) {
        path = [path stringByDeletingLastPathComponent];
        if ([path.pathExtension isEqualToString:extension]) {
            answer = path;
        }
    }

    return answer;
}

- (NSURL*)auxiliaryDataFileUrl {
    return [[self class] auxiliaryDataFileUrlForDocumentUrl:[self fileURL]];
}

+ (NSDictionary*)auxiliaryDataDictionaryFromDiskForDocumentUrl:(NSURL*)documentUrl {
    NSDictionary* dic = nil;
    NSData* data = [NSData dataWithContentsOfURL:[self auxiliaryDataFileUrlForDocumentUrl:documentUrl]];
    if (data) {
        dic = [NSPropertyListSerialization propertyListWithData:data
                                                        options:0
                                                         format:NULL
                                                          error:NULL];
    }
    if (!dic) {
        dic = [NSDictionary dictionary];
    }
    return dic;
}

- (NSDictionary*)auxiliaryDataDictionaryFromDisk {
    return [[self class] auxiliaryDataDictionaryFromDiskForDocumentUrl:[self fileURL]];
}

- (void)writeToDiskAuxiliaryDataDictionary:(NSDictionary*)dic {
    NSData* data = [NSPropertyListSerialization dataWithPropertyList:dic
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:NULL];
    NSURL* url = [self auxiliaryDataFileUrl];
    if (url) {
        [data writeToURL:url
              atomically:YES];
    } else {
        /* This failure is expected if receiver is opted into asynchronous
         saving, during the first attempt with a new document, because our
         fileURL is nil.  The subclass must have a mechanism to call this
         method again after fileURL has been set.  For example, in the
         BkmkMgrs project, our BkmxDoc subclass has such a mechanism based
         on -[BkmxDoc observeValueForKeyPath::::]. */
    }
}

- (id)auxiliaryObjectForKey:(NSString*)key {
    return [[self auxiliaryDataDictionaryFromDisk] objectForKey:key];
}

- (void)setAuxiliaryObject:(id)newObject
                    forKey:(NSString*)key {
    NSObject* existingObject = [self auxiliaryObjectForKey:key];
    if (![NSObject isEqualHandlesNilObject1:existingObject
                                    object2:newObject]) {
        NSMutableDictionary* dic = [[self auxiliaryDataDictionaryFromDisk] mutableCopy];
        if (newObject) {
            [dic setObject:newObject
                    forKey:key];
        } else {
            [dic removeObjectForKey:key];
        }

        [self writeToDiskAuxiliaryDataDictionary:dic];
#if !__has_feature(objc_arc)
        [dic release];
#endif
    }
}

- (void)addAuxiliaryKeyValues:(NSDictionary*)keyValues {
    NSDictionary* existingDic = [self auxiliaryDataDictionaryFromDisk];
    NSMutableSet* staleKeys = [NSMutableSet new];
    for (NSString* key in keyValues) {
        NSObject* newValue = [keyValues objectForKey:key];
        NSObject* oldValue = [existingDic objectForKey:key];
        if (!oldValue) {
            [staleKeys addObject:key];
        }
        else if (![newValue isEqual:oldValue]) {
            [staleKeys addObject:key];
        }
    }

    if (staleKeys.count > 0) {
        NSMutableDictionary* newDic = [existingDic mutableCopy];
        for (NSString* key in staleKeys) {
            [newDic setObject:[keyValues objectForKey:key]
                       forKey:key];
        }

        [self writeToDiskAuxiliaryDataDictionary:newDic];
#if !__has_feature(objc_arc)
        [newDic release];
#endif
    }
#if !__has_feature(objc_arc)
    [staleKeys release];
#endif
}

+ (id)auxiliaryObjectForKey:(NSString*)key
         documentPackagePath:(NSString*)documentPath {
    NSURL* documentUrl = [NSURL fileURLWithPath:documentPath];
    return [[self auxiliaryDataDictionaryFromDiskForDocumentUrl:documentUrl] objectForKey:key];
}

@end
