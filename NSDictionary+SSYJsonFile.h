#import <Foundation/Foundation.h>

@interface NSDictionary (SSYJsonFile)

/*!
 @brief    Returns a dictionary obtained by reading JSON data from a file
 at a given path
 
 @param    error_p  If the file exists but cannot be decoded into a dictionary,
 upon return, points to an NSError object describing the error
 @result   The dictionary decoded from the file, or an empty dictionary if the
 file does not exist, or nil if the file exists but cannot be decoded into
 a dictionary
 */
+ (NSDictionary*)dictionaryFromJsonAtPath:(NSString*)path
                                  error_p:(NSError**)error_p ;

@end
