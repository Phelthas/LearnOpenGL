//
//  DemoGLProgram.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/8.
//

#import "DemoGLProgram.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DemoGLUtility.h"

@interface DemoGLProgram ()

@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic, strong) NSMutableArray *uniforms;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertexShader;
@property (nonatomic, assign) GLuint fragmentShader;

@end

@implementation DemoGLProgram

- (instancetype)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString {
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray array];
        _uniforms = [NSMutableArray array];
        _program = glCreateProgram();
        
        if (![DemoGLUtility complieShader:&_vertexShader type:GL_VERTEX_SHADER shaderString:vShaderString]) {
            NSAssert(NO, @"Failed to compile vertex shader");
        }
        if (![DemoGLUtility complieShader:&_fragmentShader type:GL_FRAGMENT_SHADER shaderString:fShaderString]) {
            NSAssert(NO, @"Failed to compile fragment shader");
        }
        glAttachShader(_program, _vertexShader);
        glAttachShader(_program, _fragmentShader);
    }
    return self;
}

#pragma mark - PublicMethod

- (void)addAttribute:(NSString *)attributeName {
    if (![_attributes containsObject:attributeName]) {
        [_attributes addObject:attributeName];
        glBindAttribLocation(_program, [self attributeIndex:attributeName], attributeName.UTF8String);
    }
}

- (GLuint)attributeIndex:(NSString *)attributeName {
    return (GLuint)[_attributes indexOfObject:attributeName];
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(_program, uniformName.UTF8String);
}

- (BOOL)link {
    BOOL result = [DemoGLUtility linkProgram:_program];
    if (!result) {
        return NO;
    }
    if (_vertexShader) {
        glDeleteShader(_vertexShader);
        _vertexShader = 0;
    }
    
    if (_fragmentShader) {
        glDeleteShader(_fragmentShader);
        _fragmentShader = 0;
    }
    return YES;
}

- (void)use {
    glUseProgram(_program);
}

- (void)validate {
    [DemoGLUtility validateProgram:_program];
}

- (void)dealloc {
    if (_vertexShader) {
        glDeleteShader(_vertexShader);
        _vertexShader = 0;
    }
    
    if (_fragmentShader) {
        glDeleteShader(_fragmentShader);
        _fragmentShader = 0;
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

@end
