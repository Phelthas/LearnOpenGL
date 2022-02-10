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

- (void)setInputTextureForTarget:(id<DemoGLInputProtocol>)target;

- (DemoGLTextureFrame *)framebufferForOutput;

- (NSArray*)targets;

- (void)addTarget:(id<DemoGLInputProtocol>)newTarget;

- (void)removeTarget:(id<DemoGLInputProtocol>)targetToRemove;

- (void)removeAllTargets;

@end

NS_ASSUME_NONNULL_END
