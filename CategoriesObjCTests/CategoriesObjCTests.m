#import <XCTest/XCTest.h>
#import "NSString+SSYHttpQueryCruft.h"

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

- (void)tryRemovingQueryCruftSpecs:(NSArray <QueryCruftSpec*> *)specs
                         urlString:(NSString*)urlString
                 expectedUrlString:(NSString*)expectedUrlString
                 expectedErrorCode:(NSInteger)expectedErrorCode {
    NSError* error = nil ;
    NSString* decruftedString = [urlString urlStringByRemovingQueryCruftSpecs:specs
                                                                      error_p:&error] ;
    XCTAssertEqualObjects(decruftedString, expectedUrlString) ;
    XCTAssertEqual(error.code, expectedErrorCode) ;
}


- (void)testHttpQueryCruft {
    QueryCruftSpec* spec1 = [[QueryCruftSpec alloc] init] ;
    spec1.key = @"fref" ;
    spec1.keyIsRegex = NO ;
    spec1.domain = @"facebook.com" ;
    
    QueryCruftSpec* spec2 = [[QueryCruftSpec alloc] init] ;
    spec2.key = @"utm_(reader|source|medium|term|campaign|content)" ;
    spec2.keyIsRegex = YES ;
    spec2.domain = @"example.com" ;

    /* This spec is bad because it is an invalid regular expression. */
    QueryCruftSpec* specBad = [[QueryCruftSpec alloc] init] ;
    specBad.key = @"(*(" ;
    specBad.keyIsRegex = YES ;
    specBad.domain = nil ;  // Match any domain

    NSArray* goodSpecs = @[spec1,spec2] ;
    NSArray* badSpecs = @[spec1,spec2,specBad] ;
    
    NSString* urlIn ;
    NSString* urlEx ;
    
    /* Remove a non-regex pair in middle of query */
    urlIn = @"http://facebook.com/pages?hello=world;fref=DELETEME&foo=bar" ;
    urlEx = @"http://facebook.com/pages?hello=world&foo=bar" ;
    [self tryRemovingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove a non-regex pair at beginning of query */
    urlIn = @"http://facebook.com/pages?fref=DELETEME;hello=world;foo=bar" ;
    urlEx = @"http://facebook.com/pages?hello=world;foo=bar" ;
    [self tryRemovingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove a non-regex pair at end of query */
    urlIn = @"http://facebook.com/pages?hello=world;foo=bar&fref=DELETEME" ;
    urlEx = @"http://facebook.com/pages?hello=world;foo=bar" ;
    [self tryRemovingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Remove regex pairs at beginning, middle, and end of query, but leave one in middle */
    urlIn = @"http://me.example.com/download.html?utm_source=google&utm_medium=cpc&utm_term=hello&foo=bar&utm_content=JK%2B1142&utm_campaign=Jerry-Stuff" ;
    urlEx = @"http://me.example.com/download.html?foo=bar" ;
    [self tryRemovingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;
    
    /* Echo back a non-URL string with no error */
    urlIn = @"I am not a valid URL!!" ;
    urlEx = @"I am not a valid URL!!" ;
    [self tryRemovingQueryCruftSpecs:goodSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:0] ;

    /* Indicate error due to a bad spec */
    urlIn = @"http://google.com?foo=bar" ;
    urlEx = nil ;
    [self tryRemovingQueryCruftSpecs:badSpecs
                           urlString:urlIn
                   expectedUrlString:urlEx
                   expectedErrorCode:2048] ;
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
