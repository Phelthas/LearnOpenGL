//
//  DemoGLUtility.m
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/6.
//

#import "DemoGLUtility.h"


@implementation DemoGLUtility


+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderFileName:(NSString *)shaderFileName shaderExtension:(NSString *)shaderExtension {
    NSString *path = [[NSBundle mainBundle] pathForResource:shaderFileName ofType:shaderExtension];
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [self complieShader:shader type:type shaderString:shaderString];
}

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderString:(NSString *)shaderString {
    const GLchar *source;
    source = (GLchar *)[shaderString UTF8String];
    if (!source) {
        return false;
    }
    return [self complieShader:shader type:type shaderSource:source];
}

+ (BOOL)complieShader:(GLuint *)shader type:(GLenum)type shaderSource:(const GLchar *)shaderSource {
    GLint status = -1; //注意：如果写在第一行又不给默认值，那默认值就会是0，导致后面判断错误。

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &shaderSource, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            NSLog(@"shader compile info log: %s", log);
            free(log);
        }
        glDeleteShader(*shader);
        return false;
    }
    return true;
}


+ (BOOL)linkProgram:(GLuint)program {
    GLint status = -1;
    glLinkProgram(program);
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(program, logLength, &logLength, log);
            NSLog(@"program link info log: %s", log);
            free(log);
        }
        return false;
    }
    return true;
}

+ (GLuint)createTextureWithImage:(UIImage *)image {
    CGImageRef cgImageRef = image.CGImage;
    GLint width = (GLint)CGImageGetWidth(cgImageRef);
    GLint height = (GLint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    
    GLuint textureID;
    glGenBuffers(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

@end
