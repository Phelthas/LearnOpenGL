//
//  DemoGLContext.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLContext : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t contextQueue;
@property (nonatomic, strong, readonly) EAGLContext *context;
@property (nonatomic, readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;

+ (void *)contextKey;

+ (DemoGLContext *)sharedImageProcessingContext;

- (void)useAsCurrentContext;

+ (void)useImageProcessingContext;

- (void)prensetBufferForDisplay;

- (void)useSharegroup:(EAGLSharegroup *)sharegroup;



+ (BOOL)supportsFastTextureUpload;

@end

NS_ASSUME_NONNULL_END
