#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (SSYCryptoDigest)

- (NSData *)md5Digest {
    NSMutableData* hash = [NSMutableData dataWithLength: CC_MD5_DIGEST_LENGTH] ;
    CC_MD5([self bytes], (CC_LONG)[self length], [hash mutableBytes]) ;
    return hash ;
}

- (NSData *)sha1Digest {
    NSMutableData* hash = [NSMutableData dataWithLength: CC_SHA1_DIGEST_LENGTH] ;
    CC_SHA1([self bytes], (CC_LONG)[self length], [hash mutableBytes]) ;
    return hash ;
}

@end

// Reference: https://www.mikeash.com/pyblog/friday-qa-2012-08-10-a-tour-of-commoncrypto.html