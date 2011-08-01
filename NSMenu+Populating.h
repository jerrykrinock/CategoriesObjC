#if (MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5)

@interface NSMenu (Populating) 

/*!
 @details  Apple added this method in Mac OS X 10.6
*/
- (void)removeAllItems ;

@end

#endif