//
//  Demo4GLView.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/17.
//

#import "Demo4GLView.h"
#import "DemoGLFramebuffer.h"
#import "DemoGLProgram.h"
#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLShaders.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface Demo4GLView ()

@property (nonatomic, assign) GLint displayRotateXMatrixUniform;
@property (nonatomic, assign) GLint displayRotateYMatrixUniform;
@property (nonatomic, assign) GLint displayRotateZMatrixUniform;


@end

@implementation Demo4GLView

- (void)commonInit {
    self.contentScaleFactor = UIScreen.mainScreen.scale;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIScreen instancesRespondToSelector:@selector(nativeScale)]) {
        self.contentScaleFactor = UIScreen.mainScreen.nativeScale;
    }
#endif
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @(NO),
        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
    
    runSyncOnVideoProcessingQueue(^{
        [DemoGLContext useImageProcessingContext];
        self.displayProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageRotationVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        [self.displayProgram addAttribute:@"position"];
        [self.displayProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.displayProgram link]) {
            NSAssert(NO, @"Filter shader link failed");
        }
        self.displayPositionAttribute = [self.displayProgram attributeIndex:@"position"];
        self.displayTextureCoordinateAttribute = [self.displayProgram attributeIndex:@"inputTextureCoordinate"];
        self.displayInputTextureUniform = [self.displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        self.displayRotateXMatrixUniform = [self.displayProgram uniformIndex:@"rotateXMatrix"];
        self.displayRotateYMatrixUniform = [self.displayProgram uniformIndex:@"rotateYMatrix"];
        self.displayRotateZMatrixUniform = [self.displayProgram uniformIndex:@"rotateZMatrix"];
        
        
        glEnableVertexAttribArray(self.displayPositionAttribute);
        glEnableVertexAttribArray(self.displayTextureCoordinateAttribute);
    
        [self createDisplayFramebuffer];
    });
}

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
    runSyncOnVideoProcessingQueue(^{
        [self.displayProgram use];
        
        [self setDisplayFramebuffer];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [self.inputFrameBufferForDisplay texture]);
        glUniform1i(self.displayInputTextureUniform, 4);
        
        [self rotateXWithDegree:self.xDegree];
        [self rotateYWithDegree:self.yDegree];
        [self rotateZWithDegree:self.zDegree];
        
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        GLfloat coordinates[] = {
            0.0f, 0.0,
            1.0f, 0.0,
            0.0f, 1.0,
            1.0f, 1.0,
        };
        
        glVertexAttribPointer(self.displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer(self.displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        [self prensentFramebuffer];
        
    });
}

- (void)rotateXWithDegree:(CGFloat)degree {
    //参考https://learnopengl-cn.github.io/01%20Getting%20started/07%20Transformations/
    CGFloat radius = degree * 2 * M_PI / 360.0; //注意顺序，之前写成 180/360 结果直接变成0了，坑了自己半天
    CGFloat s = sin(radius);
    CGFloat c = cos(radius);
    //x轴方向旋转矩阵
    GLfloat rotateXMatrix[] = {
        1, 0, 0, 0,
        0, c, -s, 0,
        0, s, c, 0,
        0, 0, 0, 1,
    };
    glUniformMatrix4fv(self.displayRotateXMatrixUniform, 1, 0, rotateXMatrix);
}

- (void)rotateYWithDegree:(CGFloat)degree {
    //参考https://learnopengl-cn.github.io/01%20Getting%20started/07%20Transformations/
    CGFloat radius = degree * 2 * M_PI / 360.0; //注意顺序，之前写成 180/360 结果直接变成0了，坑了自己半天
    CGFloat s = sin(radius);
    CGFloat c = cos(radius);
    //y轴方向旋转矩阵
    GLfloat rotateYMatrix[] = {
        c, 0, s, 0,
        0, 1, 0, 0,
        -s, 0, c, 0,
        0, 0, 0, 1,
    };
    glUniformMatrix4fv(self.displayRotateYMatrixUniform, 1, 0, rotateYMatrix);
}

- (void)rotateZWithDegree:(CGFloat)degree {
    //参考https://learnopengl-cn.github.io/01%20Getting%20started/07%20Transformations/
    CGFloat radius = degree * 2 * M_PI / 360.0; //注意顺序，之前写成 180/360 结果直接变成0了，坑了自己半天
    CGFloat s = sin(radius);
    CGFloat c = cos(radius);
    //z轴方向旋转矩阵，
    GLfloat rotateZMatrix[] = {
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
    glUniformMatrix4fv(self.displayRotateZMatrixUniform, 1, 0, rotateZMatrix);
}

@end
