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

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLUtility : NSObject



+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderFileName:(NSString *)shaderFileName shaderExtension:(NSString *)shaderExtension;

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderString:(NSString *)shaderString;

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderSource:(const GLchar *)shaderSource;

+ (BOOL)linkProgram:(GLuint)program;

@end

NS_ASSUME_NONNULL_END
