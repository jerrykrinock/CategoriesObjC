#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (SSYCryptoDigest)

- (NSData *)md5Digest {
    NSMutableData* hash = [NSMutableData dataWithLength: CC_MD5_DIGEST_LENGTH] ;
    /* Using MD5 hash is deprecated in macOS 10.15.  But it is still used
     still used by Pinboard to generate a bookmark's exide from its URL,
     and by Chrome to generate the checksum for its bookmarks file.
     So, I ignore the deprecation*/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CC_MD5([self bytes], (CC_LONG)[self length], [hash mutableBytes]) ;
#pragma clang diagnostic pop
    return hash ;
}

- (NSData *)sha1Digest {
    NSMutableData* hash = [NSMutableData dataWithLength: CC_SHA1_DIGEST_LENGTH] ;
    CC_SHA1([self bytes], (CC_LONG)[self length], [hash mutableBytes]) ;
    return hash ;
}

- (NSData *)sha256Digest {
    NSMutableData* hash = [NSMutableData dataWithLength: CC_SHA256_DIGEST_LENGTH] ;
    CC_SHA256([self bytes], (CC_LONG)[self length], [hash mutableBytes]) ;
    return hash ;
}

@end

// Reference: https://www.mikeash.com/pyblog/friday-qa-2012-08-10-a-tour-of-commoncrypto.html
