//
//  DemoGLOutput.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import "DemoGLInputProtocol.h"

NS_ASSUME_NONNULL_BEGIN

void runSyncOnVideoProcessingQueue(void(^block)(void));

void runAsyncOnVideoProcessingQueue(void(^block)(void));

@interface DemoGLOutput : NSObject

// 子类会用到，暴露给外面
@property (nonatomic, strong) DemoGLFramebuffer *outputFramebuffer;

- (NSArray*)targets;

- (NSArray *)targetTextureIndices;

- (void)addTarget:(id<DemoGLInputProtocol>)newTarget;

- (void)removeTarget:(id<DemoGLInputProtocol>)targetToRemove;

- (void)removeAllTargets;

@end

NS_ASSUME_NONNULL_END
