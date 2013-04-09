#if (MAC_OS_X_VERSION_MIN_REQUIRED < 1060)

@interface NSMenu (Populating) 

/*!
 @details  Apple added this method in Mac OS X 10.6
*/
- (void)removeAllItems ;

@end

#endif