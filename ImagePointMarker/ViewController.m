//
//  ViewController.m
//  ImagePointMarker
//
//  Created by zjj on 2019/11/15.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "ViewController.h"
#import "ZZDragFileView.h"
#import "PointMarkModel.h"

#define WeakDefine(strongA, weakA) __weak typeof(strongA) weakA = strongA;

@interface ViewController() <ZZDragFileViewDelegate>

@property (nonatomic, strong) PointMarkModel *markedModel;

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSView *markedPointView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakDefine(self, weakself);
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
        [weakself keyDown:aEvent];
        return aEvent;
    }];
}

#pragma mark - getter

- (PointMarkModel *)markedModel {
    if (_markedModel == nil) {
        _markedModel = [[PointMarkModel alloc] init];
    }
    return _markedModel;
}

#pragma mark - load image file and show

- (NSImage *)resizeImage:(NSImage *)sourceImage forSize:(NSSize)size {
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);

    NSImageRep *sourceImageRep = [sourceImage bestRepresentationForRect:targetFrame context:nil hints:nil];

    NSImage *targetImage = [[NSImage alloc] initWithSize:size];

    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];

    return targetImage;
}

- (void)loadImageFile:(NSString *)filePath {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:filePath];
    image = [self resizeImage:image forSize:NSMakeSize(500, 500)];
    self.imageView.image = image;
    self.markedModel.image = image;
    self.markedModel.name = [[filePath componentsSeparatedByString:@"/"] lastObject];
    [self.markedModel.points removeAllObjects];
    [self reloadData];
}

- (void)reloadData {
    [self reloadJsonString];
    [self drawPointsInImageWithPoints:self.markedModel.points];
}

- (void)reloadJsonString {
    self.textView.string = [self.markedModel.jsonString stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n"];
    NSView *textViewSuper = self.textView.superview;
    CGRect bounds = textViewSuper.bounds;
    bounds.origin.y = self.textView.bounds.size.height - bounds.size.height;
    textViewSuper.bounds = bounds;
}

#pragma mark - point marker

- (void)addPoint:(NSPoint)point {
    if (!CGRectContainsPoint(self.markedPointView.bounds, point)) {
        return;
    }
    NSValue *value = [NSValue valueWithPoint:point];
    if ([self.markedModel.points containsObject:value]) {
        return;
    }
    [self.markedModel.points addObject:value];
    [self reloadData];
}

- (void)drawPointInImage:(NSPoint)point {
    CALayer *dot = [CALayer layer];
    dot.backgroundColor = NSColor.redColor.CGColor;
    CGFloat width = 2;
    dot.frame = CGRectMake(point.x - (width / 2), point.y - (width / 2), width, width);
    [self.markedPointView.layer addSublayer:dot];
}

- (void)clearDrawedPoints {
    NSArray *sublayers = self.markedPointView.layer.sublayers.copy;
    for (CALayer *sublay in sublayers) {
        [sublay removeFromSuperlayer];
    }
}

- (void)drawPointsInImageWithPoints:(NSArray *)points {
    [self clearDrawedPoints];
    for (NSValue *valu in points) {
        [self drawPointInImage:valu.pointValue];
    }
}

#pragma mark - ZZDragFileViewDelegate && URL decode

- (void)dragFileViewDidDragURLs:(NSArray *)URLs {
    
    NSMutableArray *decodePaths = [NSMutableArray array];
    for (NSURL *ur in URLs) {
        NSString *absStr = ur.absoluteString;
        absStr = [self humanReadablePathString:absStr];
        [decodePaths addObject:absStr];
    }
    if (decodePaths.firstObject) {
        [self loadImageFile:decodePaths.firstObject];
    }
}

- (NSString *)humanReadablePathString:(NSString *)pathString {
    pathString = [pathString stringByReplacingOccurrencesOfString:@"file:/" withString:@"/"];
    while ([pathString containsString:@"//"]) {
        pathString = [pathString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    pathString = [pathString stringByRemovingPercentEncoding];
    return pathString;
}

#pragma mark - mouse touches

- (void)mouseDown:(NSEvent *)theEvent {
//    NSLog(@"mouse down: %@", theEvent);
    NSPoint locationInWindow = theEvent.locationInWindow;
    NSPoint pointInImage = [self.view convertPoint:locationInWindow toView:self.imageView];
    [self addPoint:pointInImage];
}

#pragma mark - short cut

- (void)keyDown:(NSEvent *)event {
    unsigned short keyCode = event.keyCode;
    if (keyCode == 51) { // 退格
        [self.markedModel.points removeLastObject];
        [self reloadData];
    }
}

#pragma mark - document saving

- (void)saveDocument:(id)sender {
    [self saveDocumentAs:sender];
}

- (void)saveDocumentAs:(id)sender {
    WeakDefine(self, weakself);
    [self showSavePanelCompletionHandler:^(NSModalResponse result, NSURL *url) {
        if (result == NSModalResponseOK) {
            NSString *jsonString = weakself.markedModel.jsonString;
            [jsonString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}

- (void)showSavePanelCompletionHandler:(void (^)(NSModalResponse result, NSURL *url))handler {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"json"];
    savePanel.allowsOtherFileTypes = NO;
    WeakDefine(savePanel, weakPanel);
    [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        NSLog(@"save: %@", weakPanel.URL);
        if (handler) {
            handler(result, weakPanel.URL);
        }
    }];
}

@end
