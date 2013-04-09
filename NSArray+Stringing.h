#import <Cocoa/Cocoa.h>


/*!
 @brief     Methods for showing arrays as formatted strings
*/
@interface NSArray (Stringing)

/*!
 @brief    Lists items in the receiver in a list with newlines
 between adjacent items.

 @param    key  The key for which the value will be extracted
 and inserted into the list for each item, or nil to use the
 default key of 'description'.
 
 @param    bullet  A string which, if not nil, will be prepended
 to each line in the output.  You'll probably want this string to
 end in one or two space characters.
*/
- (NSString*)listValuesOnePerLineForKeyPath:(NSString*)key
									 bullet:(NSString*)bullet ; 

/*!
 @brief    Invokes listValuesOnePerLineForKeyPath:bullet: with
 bullet = nil
*/
- (NSString*)listValuesOnePerLineForKeyPath:(NSString*)key ;

/*!
 @brief    Returns a comma-separated list of the responses to
 each item in the receiver to a given key.
 
 @details  If the receiver is empty, returns an empty string.&nbsp;
 
 If an item does not respond to the given 'key', its response
 to -description will appear in the list.  For example, if you
 pass 'key' = "name", items which respond to -name will be
 listed as their -name and items which do not respond will be
 listed as their -description.
 
 If an item does respond to the given 'key', but the response
 is nil, not an NSString instance, or an NSString instance of
 length 0, then its contribution will be omitted from the result.
 
 Note that if you are using truncateTo, you probably don't
 want to give a conjunction and vice versa.
 @param    key  The key for which the value will be extracted
 and inserted into the list for each item, or nil to use the
 default key of 'description'.  Note that -[NSString description] is documented
 to return the receiver, so if the objects in the receiver are NSString
 instances, pass nil.
 @param    conjunction  If non-nil, and there are more than two
 items, inserts this word before the last item.  Typically this
 is a localized "&", "and" or "or"
 @param    truncateTo  The maximum number of items desired in
 the returned list.&nbsp;  If the number of items in the receiver
 exceeds this parameter, another comma and an ellipsis will
 be appended to the end.&nbsp;  For convenience, a value of 0
 is interpreted to mean NSIntegerMax.
 */
- (NSString*)listValuesForKey:(NSString*)key
				  conjunction:(NSString*)conjunction
				   truncateTo:(NSInteger)truncateTo ; 

/*!
 @brief    Invokes -[self listValuesForKey:@"name" parameters
 conjunction=nil and truncateTo=0]
*/
- (NSString*)listNames ;

@end
