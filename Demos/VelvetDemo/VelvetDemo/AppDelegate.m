//
//  AppDelegate.m
//  VelvetDemo
//
//  Created by Justin Spahr-Summers on 19.11.11.
//  Copyright (c) 2011 Bitswift. All rights reserved.
//

#import "AppDelegate.h"
#import "SquareView.h"
#import <Velvet/Velvet.h>
#import <QuartzCore/QuartzCore.h>
#import "VELDraggingDestinationView.h"
#import "MouseTrackingView.h"

@interface AppDelegate ()
@property (strong) IBOutlet VELWindow *window;
@property (strong) VELView *scrollView;
@property (strong) VELImageView *imageView;
@property (strong) SquareView *control;
@property (strong) VELNSView *buttonHost;

@property (nonatomic, strong) NSArray *views;

- (void)hierarchyTests;

- (void)draggingTests;
- (void)createViews;
- (void)animateViews;
- (void)scalingTests;
@end

@implementation AppDelegate
@synthesize window = m_window;
@synthesize scrollView = m_scrollView;
@synthesize imageView = m_imageView;
@synthesize control = m_control;
@synthesize buttonHost = m_buttonHost;
@synthesize views = m_views;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification; {
// TODO: move each test into its own window
#if 0
    [self createViews];
    [self performSelector:@selector(animateViews) withObject:nil afterDelay:2.0];
#else
//    [self draggingTests];
//    [self scalingTests];
    [self hierarchyTests];
#endif
}

- (void)scalingTests {
    VELView *containerView = [[VELView alloc] init];
    containerView.layer.backgroundColor = CGColorGetConstantColor(kCGColorWhite);
    containerView.frame = CGRectMake(100,100,100,100);



    VELNSView *backgroundView = [[VELNSView alloc] init];
    backgroundView.frame = CGRectMake(5,5, 50,50);
    CGColorRef redColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0);
    backgroundView.layer.backgroundColor = redColor;
    CGColorRelease(redColor);


    [self.window.rootView addSubview:containerView];
    [containerView addSubview:backgroundView];


    NSTextField *scalingView = [[NSTextField alloc] init];
    backgroundView.guestView = scalingView;
    [scalingView setBezelStyle:NSTextFieldSquareBezel];


    int64_t delayInSeconds = (int64_t)2.0;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:2.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        const CGFloat scale = 3.0f;
        containerView.layer.transform = CATransform3DScale(containerView.layer.transform, scale, scale, scale);
        [CATransaction commit];
    });
}


- (void)draggingTests {
    NSButton *backgroundButton = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [backgroundButton setButtonType:NSMomentaryPushInButton];
    [backgroundButton setBezelStyle:NSRoundedBezelStyle];
    [backgroundButton setTitle:@"Test Button"];
    [backgroundButton setTarget:self];
    [backgroundButton setAction:@selector(testButtonPushed:)];


    VELNSView *backgroundVELView = [[VELNSView alloc] initWithNSView:backgroundButton];
    backgroundVELView.layer.masksToBounds = YES;
    backgroundVELView.frame = CGRectMake(80, 80, 200, 200);

    VELDraggingDestinationView *view1 = [[VELDraggingDestinationView alloc] init];
    view1.frame = CGRectMake(10, 10, 200, 200);
    view1.name = @"outer";

    VELDraggingDestinationView *view2 = [[VELDraggingDestinationView alloc] init];
    view2.frame = CGRectMake(50, 50, 50, 50);
    view2.name = @"inner";

    [view1 addSubview:view2];

    [self.window.rootView addSubview:view1];
    [view1 addSubview:backgroundVELView];
}

- (void)hierarchyTests {
    // VELLabel
    {
        VELLabel *label = [[VELLabel alloc] initWithFrame:CGRectMake(0, 320, 100, 60)];
        label.backgroundColor = [NSColor whiteColor];
        label.opaque = YES;

        label.text = @"Justified text!";
        label.textColor = [NSColor blackColor];
        label.font = [NSFont systemFontOfSize:16];
        label.textAlignment = VELTextAlignmentJustified;

        [self.window.rootView addSubview:label];
    }

    // Automatic @2x images
    {
        VELImageView *imageView = [[VELImageView alloc] initWithFrame:CGRectMake(300, 320, 204, 44)];
        imageView.image = [NSImage imageNamed:@"image"];

        [self.window.rootView addSubview:imageView];
    }

    // NSScrollView
    {
        NSScrollView *nsScrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
        nsScrollView.hasHorizontalScroller = YES;
        nsScrollView.hasVerticalScroller = YES;
        nsScrollView.usesPredominantAxisScrolling = NO;

        nsScrollView.backgroundColor = [NSColor whiteColor];
        nsScrollView.drawsBackground = YES;

        VELClickEventRecognizer *clickRecognizer = [[VELClickEventRecognizer alloc] init];
        clickRecognizer.numberOfClicksRequired = 2;
        clickRecognizer.delaysEventDelivery = NO;
        clickRecognizer.view = nsScrollView;
        clickRecognizer.handlesEventsAfterDescendants = YES;

        [clickRecognizer addActionUsingBlock:^(VELClickEventRecognizer *clickRecognizer){
            if (clickRecognizer.active)
                NSLog(@"Scroll view double-click at %@", NSStringFromPoint([clickRecognizer locationInView:nsScrollView]));
        }];

        clickRecognizer.shouldReceiveEventBlock = ^(NSEvent *event){
            if (event.locationInWindow.x > 300) {
                NSLog(@"Discarding event at X > 300: %@", event);
                return NO;
            }

            return YES;
        };

        VELNSView *scrollViewHost = [[VELNSView alloc] initWithNSView:nsScrollView];
        scrollViewHost.backgroundColor = [NSColor yellowColor];

        [self.window.rootView addSubview:scrollViewHost];

        NSVelvetView *velvetView = [[NSVelvetView alloc] initWithFrame:CGRectMake(0, 0, 700, 700)];
        [nsScrollView setDocumentView:velvetView];

        self.scrollView = velvetView.guestView;
    }

    // VELImageView
    {
        NSImage *image = [NSImage imageNamed:@"iceberg.jpg"];

        self.imageView = [[VELImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
        self.imageView.image = image;

        // 44px on every corner should not scale, while the rest of the image should
        self.imageView.endCapInsets = NSEdgeInsetsMake(44, 44, 44, 44);

        [self.scrollView addSubview:self.imageView];
    }

    // VELControl subclass
    {
        self.control = [[SquareView alloc] initWithFrame:CGRectMake(60, 60, 100, 100)];
        self.control.clipsToBounds = YES;

        [self.control addActionForControlEvents:VELControlEventMouseUpInside usingBlock:^(NSEvent *event){
            NSLog(@"Square view click action with event: %@", event);
        }];

        VELClickEventRecognizer *doubleClickRecognizer = [[VELClickEventRecognizer alloc] init];
        doubleClickRecognizer.numberOfClicksRequired = 2;
        doubleClickRecognizer.delaysEventDelivery = NO;
        doubleClickRecognizer.view = self.control;

        [doubleClickRecognizer addActionUsingBlock:^(VELClickEventRecognizer *doubleClickRecognizer){
            if ([doubleClickRecognizer isActive])
                NSLog(@"Square view event recognizer double-click at %@", NSStringFromPoint([doubleClickRecognizer locationInView:self.control]));
        }];

        VELClickEventRecognizer *quadrupleClickRecognizer = [[VELClickEventRecognizer alloc] init];
        quadrupleClickRecognizer.numberOfClicksRequired = 4;
        quadrupleClickRecognizer.delaysEventDelivery = NO;
        quadrupleClickRecognizer.view = self.control;

        // allow quadruple-clicks to prevent double-clicks
        doubleClickRecognizer.shouldBePreventedByEventRecognizerBlock = ^(VELEventRecognizer *recognizer, NSEvent *event){
            if (!(event.type == NSLeftMouseDown || event.type == NSLeftMouseUp))
                return NO;

            if (recognizer != quadrupleClickRecognizer)
                return NO;

            return event.clickCount == 4;
        };

        [quadrupleClickRecognizer addActionUsingBlock:^(VELClickEventRecognizer *quadrupleClickRecognizer){
            if ([quadrupleClickRecognizer isActive])
                NSLog(@"Square view event recognizer quadruple click at %@", NSStringFromPoint([quadrupleClickRecognizer locationInView:self.control]));
        }];

        [self.scrollView addSubview:self.control];
    }

    // NSButton
    {
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 80, 28)];
        [button setButtonType:NSMomentaryPushInButton];
        [button setBezelStyle:NSRoundedBezelStyle];
        [button setTitle:@"Test Button"];
        [button setTarget:self];
        [button setAction:@selector(testButtonPushed:)];

        self.buttonHost = [[VELNSView alloc] initWithNSView:button];
        self.buttonHost.backgroundColor = [NSColor blueColor];
        [self.control addSubview:self.buttonHost];
    }

    // Mouse Tracking View
    {
        MouseTrackingView *trackingView = [[MouseTrackingView alloc] initWithFrame:CGRectMake(200, 20, 300, 300)];
        [self.scrollView addSubview:trackingView];

        MouseTrackingView *innerTrackingView = [[MouseTrackingView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
        innerTrackingView.normalColor = [NSColor colorWithCalibratedRed:0.2 green:0.3 blue:0.4 alpha:1.0];
        innerTrackingView.dotColor = [NSColor colorWithCalibratedRed:0.6 green:0.1 blue:0.1 alpha:1.0];
        [trackingView addSubview:innerTrackingView];
    }

    // NSTextField
    {
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 180, 91, 22)];
        [textField.cell setUsesSingleLineMode:YES];
        [textField.cell setScrollable:YES];

        VELKeyPressEventRecognizer *recognizer = [[VELKeyPressEventRecognizer alloc] init];
        recognizer.view = textField;
        recognizer.keyPressesToRecognize = [NSArray arrayWithObjects:
            [[VELKeyPress alloc] initWithCharactersIgnoringModifiers:@"h" modifierFlags:0],
            [[VELKeyPress alloc] initWithCharactersIgnoringModifiers:@"i" modifierFlags:0],
            nil
        ];

        [recognizer addActionUsingBlock:^(VELKeyPressEventRecognizer *recognizer){
            if (recognizer.active)
                NSLog(@"Hi to you too!");
        }];

        VELNSView *textFieldHost = [[VELNSView alloc] initWithNSView:textField];
        textFieldHost.backgroundColor = [NSColor greenColor];
        [self.scrollView addSubview:textFieldHost];
    }
}

- (void)testButtonPushed:(id)sender {
    NSLog(@"testButtonPushed");

    [VELView animateWithDuration:2 animations:^{
        self.buttonHost.alpha = 0;
    } completion:^{
        [VELView animateWithDuration:5 animations:^{
            self.buttonHost.alpha = 1;
        }];
    }];
}


- (NSImage *)loadLolz {
    NSImage *image = [NSImage imageNamed:@"lolcats.jpg"];
    return image;
}

- (void)createViews {
    const NSUInteger numViews = 900;
    const NSUInteger numCols = 30;

    NSMutableArray *views = [NSMutableArray arrayWithCapacity:numViews];

    NSImage *image = [self loadLolz];

    for (NSUInteger i = 0; i < numViews; ++i) {
        VELImageView *v = [[VELImageView alloc] init];
        v.image = image;
        v.frame = NSMakeRect((i % numCols) * 60, (i / numCols) * 60, 50, 50);
        [views addObject:v];
    }

    self.window.rootView.subviews = views;
    self.views = views;
}

- (void)animateViews {

    id completionBlock = ^ {
        [self performSelector:_cmd withObject:nil afterDelay:0.2];
    };

    void (^animationBlock)(void) = ^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:completionBlock];

        for (NSUInteger i = 0; i < self.views.count / 2; ++i) {
            VELView *v = [self.views objectAtIndex:i];
            NSUInteger j = self.views.count - i - 1; // RandomInRange(i, self.views.count);
            VELView *w = [self.views objectAtIndex:j];

            CGPoint vPos = v.layer.position;
            CGPoint wPos = w.layer.position;

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//            animation.isRemovedOnCompletion = NO;
            animation.fromValue = [NSValue valueWithPoint:vPos];
            animation.toValue = [NSValue valueWithPoint:wPos];
            animation.duration = 1;
            [v.layer addAnimation:animation forKey:@"posAnim"];

            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
//            animation2.isRemovedOnCompletion = NO;
            animation2.fromValue = [NSValue valueWithPoint:wPos];
            animation2.toValue = [NSValue valueWithPoint:vPos];
            animation2.duration = 1;
            [w.layer addAnimation:animation2 forKey:@"posAnim"];
        }

        [CATransaction commit];
    };

    animationBlock();

    //[NSAnimationContext runAnimationGroup:animationBlock completionHandler:completionBlock];
}

@end

