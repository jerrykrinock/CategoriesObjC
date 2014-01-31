#import <Foundation/Foundation.h>

@interface NSUserDefaults (SSYOtherApps)

- (void)syncApplicationId:(NSString*)applicationId ;

- (void)setValue:(id)value
          forKey:(NSString*)key
   applicationId:(NSString*)applicationId ;

- (void)setAndSyncValue:(id)value
                 forKey:(NSString*)key
          applicationId:(NSString*)applicationId ;

- (NSObject*)valueForKey:(NSString*)key
           applicationId:(NSString*)applicationId ;

- (NSObject*)syncAndGetValueForKey:(NSString*)key
                     applicationId:(NSString*)applicationId ;

- (id)valueForKeyPathArray:(NSArray*)keyPathArray
             applicationId:(NSString*)applicationId ;

- (id)syncAndGetValueForKeyPathArray:(NSArray*)keyPathArray
                       applicationId:(NSString*)applicationId ;

- (void)setAndSyncValue:(id)value
        forKeyPathArray:(NSArray*)keyArray
          applicationId:(NSString*)applicationId ;

- (void)       removeAndSyncKey:(id)key
                  applicationId:(NSString*)applicationId ;

- (void)       removeAndSyncKey:(id)key
   fromDictionaryAtKeyPathArray:(NSArray*)keyPathArray
                  applicationId:(NSString*)applicationId ;

@end
