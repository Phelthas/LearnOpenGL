//
//  DemoGLFramebuffer.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>

typedef struct DemoGLTextureOptions {
    GLenum minFilter;
    GLenum magFilter;
    GLenum wrapS;
    GLenum wrapT;
    GLenum internalFormat;
    GLenum format;
    GLenum type;
} DemoGLTextureOptions;


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLFramebuffer : NSObject


/// @param onlyGenerateTexture 是否只生成texture；默认是NO，会同时生成frameBuffer；
- (instancetype)initWithSize:(CGSize)framebufferSize textureOptions:(DemoGLTextureOptions)textureOptions onlyGenerateTexture:(BOOL)onlyGenerateTexture;

- (instancetype)initWithSize:(CGSize)framebufferSize onlyGenerateTexture:(BOOL)onlyGenerateTexture;

- (instancetype)initWithSize:(CGSize)framebufferSize;

- (void)activateFramebuffer;

- (GLuint)texture;

- (GLubyte *)byteBuffer;

- (int)width;

- (int)height;

@end

NS_ASSUME_NONNULL_END
