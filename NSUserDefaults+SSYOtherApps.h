#import <Foundation/Foundation.h>

@interface NSUserDefaults (SSYOtherApps)

- (void)syncApplicationId:(NSString*)applicationId ;

- (void)setValue:(id)value
          forKey:(NSString*)key
   applicationId:(NSString*)applicationId ;

- (void)setAndSyncValue:(id)value
                 forKey:(NSString*)key
          applicationId:(NSString*)applicationId ;

- (id)valueForKey:(NSString*)key
    applicationId:(NSString*)applicationId ;

- (id)syncAndGetValueForKey:(NSString*)key
              applicationId:(NSString*)applicationId ;

- (id)valueForKeyPathArray:(NSArray*)keyPathArray
             applicationId:(NSString*)applicationId ;

- (id)syncAndGetValueForKeyPathArray:(NSArray*)keyPathArray
                       applicationId:(NSString*)applicationId ;

/*
 @details  If 'value' is nil, this method will be a no-op.  To remove a value,
 you should instead use one of the -remove… methods in this category. */
- (void)setAndSyncValue:(id)value
        forKeyPathArray:(NSArray*)keyArray
          applicationId:(NSString*)applicationId ;

- (void)removeAndSyncKey:(id)key
           applicationId:(NSString*)applicationId ;

- (void)removeAndSyncKeyPathArray:(NSArray*)keyPathArray
                    applicationId:(NSString*)applicationId;

- (void)       removeAndSyncKey:(id)key
   fromDictionaryAtKeyPathArray:(NSArray*)keyPathArray
                  applicationId:(NSString*)applicationId ;

@end
