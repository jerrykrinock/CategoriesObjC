#import <XCTest/XCTest.h>
#import "NSString+SSYHttpQueryCruft.h"
#import "NSString+SSYDotSuffix.h"

@interface CategoriesObjCTests : XCTestCase

@end

@implementation CategoriesObjCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)tryProcessingQueryCruftSpecs:(NSArray <NSDictionary*> *)specs
                           urlString:(NSString*)urlString
                      expectedRanges:(NSArray*)expectedRanges
                   expectedUrlString:(NSString*)expectedUrlString
                   expectedErrorCode:(NSInteger)expectedErrorCode {
    NSError* error = nil ;
    NSArray* ranges = [urlString rangesOfQueryCruftSpecs:specs
                                                 error_p:&error] ;
    XCTAssertEqual(error.code, expectedErrorCode) ;
    XCTAssertEqualObjects(ranges, expectedRanges) ;
    
    NSString* decruftedUrlString = [urlString urlStringByRemovingCruftyQueryPairsInRanges:ranges] ;
    XCTAssertEqualObjects(decruftedUrlString, expectedUrlString) ;

}

- (void)testHttpQueryCruft {
    NSDictionary* spec1 = @{
                            constKeyCruftDomain : @"facebook.com",
                            constKeyCruftKey : @"fref",
                            constKeyCruftKeyIsRegex : @NO
                            } ;
    
    NSDictionary* spec2 = @{
                            constKeyCruftDomain : @"example.com",
                            constKeyCruftKey : @"utm_(reader|source|medium|term|campaign|content)",
                            constKeyCruftKeyIsRegex : @YES
                            } ;
    
    /* This spec is bad because it is an invalid regular expression. */
    NSDictionary* specBad = @{
                              // constKeyCruftDomain omitted --> Match any domain
                              constKeyCruftKey : @"(*(",
                              constKeyCruftKeyIsRegex : @YES
                              } ;

    NSArray* goodSpecs = @[spec1,spec2] ;
    NSArray* badSpecs = @[spec1,spec2,specBad] ;
    
    NSString* urlIn ;
    NSString* urlEx ;
    NSArray* ranges ;
    
    /* Remove a non-regex pair in middle of query */
    urlIn = @"http://facebook.com/pages?hello=world;fref=DELETEME&foo=bar" ;
    urlEx = @"http://facebook.com/pages?hello=world;foo=bar" ;
    ranges = @[@"{38, 13}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove a non-regex pair at beginning of query */
    urlIn = @"http://facebook.com/pages?fref=DELETEME;hello=world;foo=bar" ;
    urlEx = @"http://facebook.com/pages?hello=world;foo=bar" ;
    ranges = @[@"{26, 13}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove a non-regex pair at end of query */
    urlIn = @"http://facebook.com/pages?hello=world;foo=bar&fref=DELETEME" ;
    urlEx = @"http://facebook.com/pages?hello=world;foo=bar" ;
    ranges = @[@"{46, 13}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove regex pairs at beginning, middle, and end of query, but one good one in the middle */
    urlIn = @"http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&foo=bar&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff" ;
    urlEx = @"http://me.example.com/download.html?foo=bar" ;
    ranges = @[@"{36, 17}", @"{54, 14}", @"{69, 14}", @"{92, 21}", @"{114, 24}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Repeat the above with a fragment in the URL */
    urlIn = @"http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&foo=bar&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff#MyFragment" ;
    urlEx = @"http://me.example.com/download.html?foo=bar#MyFragment" ;
    ranges = @[@"{36, 17}", @"{54, 14}", @"{69, 14}", @"{92, 21}", @"{114, 24}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                             urlString:urlIn
                        expectedRanges:ranges
                     expectedUrlString:urlEx
                     expectedErrorCode:0] ;
    
    /* Repeat the above with good queries at the beginning and end */
    urlIn = @"http://me.example.com/download.html?goodOne=1;utm_source=google&utm_medium=cpc&utm_term=hello&foo=bar&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff;anotherGoodOne=Bird#MyFragment" ;
    urlEx = @"http://me.example.com/download.html?goodOne=1;foo=bar&anotherGoodOne=Bird#MyFragment" ;
    ranges = @[@"{46, 17}", @"{64, 14}", @"{79, 14}", @"{102, 21}", @"{124, 24}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                             urlString:urlIn
                        expectedRanges:ranges
                     expectedUrlString:urlEx
                     expectedErrorCode:0] ;
    
    /* Repeat the above, with no good key/value pairs, so that the entire query string disappears. */
    urlIn = @"http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff#MyFragment" ;
    urlEx = @"http://me.example.com/download.html#MyFragment" ;
    ranges = @[@"{36, 17}", @"{54, 14}", @"{69, 14}", @"{84, 21}", @"{106, 24}"] ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                             urlString:urlIn
                        expectedRanges:ranges
                     expectedUrlString:urlEx
                     expectedErrorCode:0] ;
    
    /* Echo back a non-URL string with no error */
    urlIn = @"I am not a valid URL!!" ;
    urlEx = @"I am not a valid URL!!" ;
    ranges = nil ;
    [self tryProcessingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;

    /* Indicate error due to a bad spec */
    urlIn = @"http://google.com?foo=bar" ;
    urlEx = @"http://google.com?foo=bar" ;
    ranges = nil ;
    [self tryProcessingQueryCruftSpecs:badSpecs
                           urlString:urlIn
                        expectedRanges:ranges
                   expectedUrlString:urlEx
                   expectedErrorCode:2048] ;
}

- (void)testStringDotSuffix {
    NSString* sIn ;
    NSString* sOut ;
    
    // Reverse-DNS identifier with spaces
    sIn = @"com.apple.developer tools" ;
    sOut = [sIn stringByDeletingDotSuffix] ;
    XCTAssertEqualObjects(sOut, @"com.apple", @"stringByDeletingDotSuffix Failed on %@", sIn) ;
    sOut = [sOut stringByAppendingDotSuffix:@"developer tools"] ;
    XCTAssertEqualObjects(sOut, sIn, @"stringByDeletingDotSuffix Failed on %@", sOut) ;

    // Path with spaces and non-ASCII characters in filename and extension
    sIn = @"/path/to/what ever––do.my ⌘ extension" ;
    sOut = [sIn stringByDeletingDotSuffix] ;
    XCTAssertEqualObjects(sOut, @"/path/to/what ever––do", @"stringByDeletingDotSuffix Failed on %@", sIn) ;
    sOut = [sOut stringByAppendingDotSuffix:@"my ⌘ extension"] ;
    XCTAssertEqualObjects(sOut, sIn, @"stringByDeletingDotSuffix Failed on %@", sOut) ;

    // String with no dots
    sIn = @"hello world" ;
    sOut = [sIn stringByDeletingDotSuffix] ;
    XCTAssertEqualObjects(sOut, sIn, @"stringByDeletingDotSuffix Failed on %@", sIn) ;
    sOut = [sOut stringByAppendingDotSuffix:nil] ;
    XCTAssertEqualObjects(sOut, sIn, @"stringByDeletingDotSuffix Failed on %@", sOut) ;

    // String with empty dot suffix
    sIn = @"hello world." ;
    sOut = [sIn stringByDeletingDotSuffix] ;
    XCTAssertEqualObjects(sOut, @"hello world", @"stringByDeletingDotSuffix Failed on %@", sIn) ;
    sOut = [sOut stringByAppendingDotSuffix:@""] ;
    XCTAssertEqualObjects(sOut, sIn, @"stringByDeletingDotSuffix Failed on %@", sOut) ;

}

#if 0
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
#endif
@end
