//
//  Demo5GLView.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/2.
//

#import "Demo5GLView.h"
#import "DemoGLDefines.h"
#import "DemoGLFramebuffer.h"
#import "DemoGLProgram.h"
#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLShaders.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


DemoGLVertex initVertices[] = {
    {{-1.0f, -1.0f,}, {0.0f, 0.0,}},
    {{1.0f, -1.0f,}, {1.0f, 0.0,}},
    {{-1.0f, 1.0f,}, {0.0f, 1.0,}},
    {{1.0f, 1.0f,}, {1.0f, 1.0,}},
};

@interface Demo5GLView () {
    DemoGLVertex _vertexArray[4];
}

@property (nonatomic, assign) GLuint vbo;

@end

@implementation Demo5GLView

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
        self.displayProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        [self.displayProgram addAttribute:@"position"];
        [self.displayProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.displayProgram link]) {
            NSAssert(NO, @"Filter shader link failed");
        }
        self.displayPositionAttribute = [self.displayProgram attributeIndex:@"position"];
        self.displayTextureCoordinateAttribute = [self.displayProgram attributeIndex:@"inputTextureCoordinate"];
        self.displayInputTextureUniform = [self.displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        
        
        glEnableVertexAttribArray(self.displayPositionAttribute);
        glEnableVertexAttribArray(self.displayTextureCoordinateAttribute);
    
        [self createDisplayFramebuffer];
        
//        [self createVBO];

    });
}

- (void)createVBO {
    
    _vertexArray[0] = (DemoGLVertex){{-0.5f, -0.5f,}, {0.0f, 0.0f,}};
    _vertexArray[1] = (DemoGLVertex){{0.5f, -0.5f,}, {1.0f, 0.0f,}};
    _vertexArray[2] = (DemoGLVertex){{-0.5f, 0.5f,}, {0.0f, 1.0f,}};
    _vertexArray[3] = (DemoGLVertex){{0.5f, 0.5f,}, {1.0f, 1.0f,}};
    
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(_vertexArray), _vertexArray, GL_STATIC_DRAW);

    
    glVertexAttribPointer(self.displayPositionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(DemoGLVertex), (void *)offsetof(DemoGLVertex, position));
    glEnableVertexAttribArray(self.displayPositionAttribute);

    glVertexAttribPointer(self.displayTextureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(DemoGLVertex), (void *)offsetof(DemoGLVertex, textureCoordinate));
    glEnableVertexAttribArray(self.displayTextureCoordinateAttribute);
    
    GetGLErrorOC();

//    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
    
    runSyncOnVideoProcessingQueue(^{
        [self.displayProgram use];
        
        [self setDisplayFramebuffer];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [self.inputFrameBufferForDisplay texture]);
        glUniform1i(self.displayInputTextureUniform, 4);
        
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        static const GLfloat coordinates[] = {
            0.0f, 0.0,
            1.0f, 0.0,
            0.0f, 1.0,
            1.0f, 1.0,
        };
        
        glVertexAttribPointer(self.displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer(self.displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        [self prensentFramebuffer];
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
    });
}

@end
