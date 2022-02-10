//
//  DemoGLOutput.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLTextureFrame.h"

void runSyncOnVideoProcessingQueue(void(^block)(void)) {
    dispatch_queue_t videoProcessingQueue = [DemoGLContext sharedImageProcessingContext].contextQueue;
    if (dispatch_get_specific([DemoGLContext contextKey])) {
        block();
    } else {
        dispatch_sync(videoProcessingQueue, block);
    }
}

void runAsyncOnVideoProcessingQueue(void(^block)(void)) {
    dispatch_queue_t videoProcessingQueue = [DemoGLContext sharedImageProcessingContext].contextQueue;
    if (dispatch_get_specific([DemoGLContext contextKey])) {
        block();
    } else {
        dispatch_async(videoProcessingQueue, block);
    }
}

@interface DemoGLOutput ()

@property (nonatomic, strong) NSMutableArray *targets;
@property (nonatomic, strong) DemoGLTextureFrame *outputTextureFrame;


@end

@implementation DemoGLOutput

- (instancetype)init {
    self = [super init];
    if (self) {
        _targets = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self removeAllTargets];
}

- (DemoGLTextureFrame *)framebufferForOutput {
    return _outputTextureFrame;
}

- (void)setInputTextureForTarget:(id<DemoGLInputProtocol>)target {
    [target setInputTexture:[self framebufferForOutput]];
}

- (NSArray *)targets {
    return [_targets copy];
}

- (void)addTarget:(id<DemoGLInputProtocol>)target {
    [_targets addObject:target];
}

- (void)removeTarget:(id<DemoGLInputProtocol>)target {
    if (![_targets containsObject:target]) {
        return;
    }
    runSyncOnVideoProcessingQueue(^{
        [self->_targets removeObject:target];
    });
}

- (void)removeAllTargets {
    runSyncOnVideoProcessingQueue(^{
        [self->_targets removeAllObjects];
    });
}

@end
