//
//  Demo4_4GLView.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/19.
//

#import "Demo4_4GLView.h"
#import "DemoGLFramebuffer.h"
#import "DemoGLProgram.h"
#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLShaders.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface Demo4_4GLView ()

@property (nonatomic, assign) GLint displayRotateMatrixUniform;
@property (nonatomic, assign) GLint displayScaleMatrixUniform;

@end

@implementation Demo4_4GLView

- (void)commonInit {
    self.contentScaleFactor = UIScreen.mainScreen.scale;
    _rotateMatrix = CATransform3DIdentity;
    _scaleMatrix = CATransform3DIdentity;
    
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
        self.displayProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageTransversalVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        [self.displayProgram addAttribute:@"position"];
        [self.displayProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.displayProgram link]) {
            NSAssert(NO, @"Filter shader link failed");
        }
        self.displayPositionAttribute = [self.displayProgram attributeIndex:@"position"];
        self.displayTextureCoordinateAttribute = [self.displayProgram attributeIndex:@"inputTextureCoordinate"];
        self.displayInputTextureUniform = [self.displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        self.displayRotateMatrixUniform = [self.displayProgram uniformIndex:@"rotateMatrix"];
        self.displayScaleMatrixUniform = [self.displayProgram uniformIndex:@"scaleMatrix"];
        
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
        
        [self setupWithScaleMatrix:self.scaleMatrix];
        [self setupWithRotateMatrix:self.rotateMatrix];


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

- (void)setupWithRotateMatrix:(CATransform3D)transform {
    //        //         转置矩阵
    //        GLfloat rotateZMatrix[] = {
    //            self.rotateZMatrix.m11, self.rotateZMatrix.m21, self.rotateZMatrix.m31, self.rotateZMatrix.m41,
    //            self.rotateZMatrix.m12, self.rotateZMatrix.m22, self.rotateZMatrix.m32, self.rotateZMatrix.m42,
    //            self.rotateZMatrix.m13, self.rotateZMatrix.m23, self.rotateZMatrix.m33, self.rotateZMatrix.m43,
    //            self.rotateZMatrix.m14, self.rotateZMatrix.m24, self.rotateZMatrix.m34, self.rotateZMatrix.m44,
    //        };
            
    //             正常矩阵
    GLfloat rotateMatrix[] = {
        transform.m11, transform.m12, transform.m13, transform.m14,
        transform.m21, transform.m22, transform.m23, transform.m24,
        transform.m31, transform.m32, transform.m33, transform.m34,
        transform.m41, transform.m42, transform.m43, transform.m44,
    };
    glUniformMatrix4fv(self.displayRotateMatrixUniform, 1, 0, rotateMatrix);
}

- (void)setupWithScaleMatrix:(CATransform3D)transform {
            
    //             正常矩阵
    GLfloat scaleMatrix[] = {
        transform.m11, transform.m12, transform.m13, transform.m14,
        transform.m21, transform.m22, transform.m23, transform.m24,
        transform.m31, transform.m32, transform.m33, transform.m34,
        transform.m41, transform.m42, transform.m43, transform.m44,
    };
    glUniformMatrix4fv(self.displayScaleMatrixUniform, 1, 0, scaleMatrix);
}

@end

