//
//  DemoGLOutput.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLFramebuffer.h"

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

@property (nonatomic, strong) NSMutableArray<id<DemoGLInputProtocol>> *targetArray;

/// 在addTarget的时候，自己在target中的index；
/// 因为可能有多个output添加了同一个target，所以必须要知道自己在target中的index；
/// 这个index是在addTarget的时候，由target提供的
@property (nonatomic, strong) NSMutableArray<NSNumber *> *targetTextureIndexArray;

@end

@implementation DemoGLOutput

- (instancetype)init {
    self = [super init];
    if (self) {
        _targetArray = [NSMutableArray array];
        _targetTextureIndexArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self removeAllTargets];
}



- (NSArray *)targets {
    return [_targetArray copy];
}

- (NSArray *)targetTextureIndices {
    return [_targetTextureIndexArray copy];
}

- (void)addTarget:(id<DemoGLInputProtocol>)target {
    NSAssert(![self.targets containsObject:target], @"already contains target:%@", target);
    // 注意！！！这一句非常关键，target中inputframebuffer的顺序就是在这里确定的
    NSInteger nextAvailableTextureIndex = [target nextAvailableTextureIndex];
    runSyncOnVideoProcessingQueue(^{
        [target setInputFramebuffer:self.outputFramebuffer atIndex:nextAvailableTextureIndex];
        [self.targetArray addObject:target];
        [self.targetTextureIndexArray addObject:@(nextAvailableTextureIndex)];
    });
    
}

- (void)removeTarget:(id<DemoGLInputProtocol>)target {
    if (![self.targetArray containsObject:target]) {
        return;
    }
    runSyncOnVideoProcessingQueue(^{
        NSInteger indexToRemove = [self.targetArray indexOfObject:target];
        NSNumber *textureIndex = self.targetTextureIndexArray[indexToRemove];
        [self.targetTextureIndexArray removeObject:textureIndex];
        [self.targetArray removeObject:target];
    });
}

- (void)removeAllTargets {
    runSyncOnVideoProcessingQueue(^{
        [self.targetTextureIndexArray removeAllObjects];
        [self.targetArray removeAllObjects];
    });
}

@end
