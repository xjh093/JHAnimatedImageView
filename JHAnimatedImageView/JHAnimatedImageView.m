//
//  JHAnimatedImageView.m
//  JHKit
//
//  Created by HaoCold on 16/8/11.
//  Copyright © 2016年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "JHAnimatedImageView.h"

@interface JHAnimatedImageView ()
@property (nonatomic,  strong) NSArray *paths;
@property (nonatomic,  assign) NSTimeInterval  frameTime;
@property (nonatomic,  strong) NSOperationQueue *animationOperationQueue;
@property (nonatomic,  assign) NSInteger  index;
@property (nonatomic,  assign) BOOL  animatingNow;
@end

@implementation JHAnimatedImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _removeWhenFinished = YES;
    }
    return self;
}

#pragma mark - override
- (void)startAnimating{
    if (_animationImagePaths.count == 0 || _animatingNow) {
        return;
    }
    
    _animatingNow = YES;
    _paths = [_animationImagePaths copy];
    _frameTime = self.animationDuration / _paths.count;
    
    [self display];
}

- (void)stopAnimating{
    [self.animationOperationQueue cancelAllOperations];
}

#pragma mark - public

- (BOOL)isAnimatingNow{
    return _animatingNow;
}

- (void)pauseAnimating:(BOOL)pause{
    [self.animationOperationQueue setSuspended:pause];
}

#pragma mark - private

- (void)display
{
    __weak typeof(self) weakSelf = self;
    NSEnumerator *enumerator = _paths.objectEnumerator;
    NSString *imagePath = [enumerator nextObject];
    while (imagePath) {
        [self.animationOperationQueue addOperationWithBlock:^{
            [weakSelf display:imagePath];
        }];
        imagePath = [enumerator nextObject];
    }
}

- (void)display:(NSString *)imagePath
{
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:data];
    CGImageRef imageRef = image.CGImage;
    
//===> The following code is quoted from 'YYImageCoder.m'
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) return;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
//===>
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        weakSelf.layer.contents = CFBridgingRelease(newImage);
        _index++;
        if (_index == _paths.count) {
            weakSelf.animationRepeatCount--;
            if (weakSelf.animationRepeatCount > 0) {
                _index = 0;
                [weakSelf display];
            }else{
                weakSelf.animatingNow = NO;
                if (weakSelf.removeWhenFinished) {
                    [weakSelf removeFromSuperview];
                }
            }
        }
    }];
    [NSThread sleepForTimeInterval:_frameTime];
}

- (NSOperationQueue *)animationOperationQueue{
    if (!_animationOperationQueue) {
        _animationOperationQueue = [[NSOperationQueue alloc] init];
        _animationOperationQueue.maxConcurrentOperationCount = 1;
        _animationOperationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    }
    return _animationOperationQueue;
}

@end

