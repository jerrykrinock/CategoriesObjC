@interface NSData (SSYCryptoDigest)

- (NSData *)md5Digest;
- (NSData *)sha1Digest;
- (NSData *)sha256Digest;

@end
