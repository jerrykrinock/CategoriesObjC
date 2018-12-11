#import "NSRunningApplication+SSYHideReliably.h"

@implementation NSRunningApplication (SSYHideReliably)

- (void)hideReliablyWithGuardInterval:(NSTimeInterval)guardInterval {
/*
 What I would like to do in this method is to
 send -hide repeatedly until something indicates that the app is hidden, or a
 few-seconds timeout, whichever comes first.  However, I've not been able to
 find any such indication that works.  Following is a list of what I've tried.
 My test was to launch and hide Firefox 33.0 in macOS 10.10.1, date 20141119.
 Repeated with Chrome in macOS 10.14.2 on 20181210; same results.

 • The documentation of NSRunningApplication, at the beginning, explains how the
 -isHidden property is fixed for a run loop cycle. So, as expected, that does
 not work.  I tried running the run loop, but I'm never sure how to do that,
 and it didn't work, and it would be a bad design even if it did seem to work.
 • The return value of -[NSRunningApplication hide] is supposed to indicate
 success or failure, but it does not work.  It returns NO even when it succeeds.
 I suppose maybe someone at Apple did not read the documentation and used
 -isHidden as an indicator?
 • I tried to get around the run loop thing by invoking -isHidden with in a
 block, invoked by dispatch_sync(), but it always returned NO too, even if
 Firefox was successfully hidden.  Apparently, secondary threads are still
 subject to the same run loop limitation in NSRunningApplication?

 So I gave up and used this stinking open-loop solution that seems to work.
 I test the -isHidden anyhow, in case Apple ever fixes it.
*/
    NSDate* startTime = [NSDate date];
    BOOL isHidden = NO;
    while ((-[startTime timeIntervalSinceNow] < guardInterval)  && !isHidden) {
        isHidden = [self hide];
        [NSThread sleepForTimeInterval:0.05];
    }
}

@end
