//
//  DemoGLUtility.h
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


#if !defined(_STRINGIFY)
#define __STRINGIFY( _x )   # _x
#define _STRINGIFY( _x )   __STRINGIFY( _x )
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLUtility : NSObject



+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderFileName:(NSString *)shaderFileName shaderExtension:(NSString *)shaderExtension;

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderString:(NSString *)shaderString;

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderSource:(const GLchar *)shaderSource;

+ (BOOL)linkProgram:(GLuint)program;

+ (BOOL)validateProgram:(GLuint)program;

+ (GLuint)createTextureWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
