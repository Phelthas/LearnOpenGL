//
//  DemoGLFilter.m
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/19.
//

#import "DemoGLFilter.h"
#import "DemoGLShaders.h"
#import "DemoGLContext.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface DemoGLFilter ()

@property (nonatomic, assign) CGSize inputTextureSize;
@property (nonatomic, assign) CGFloat backgroundColorRed;
@property (nonatomic, assign) CGFloat backgroundColorGreen;
@property (nonatomic, assign) CGFloat backgroundColorBlue;
@property (nonatomic, assign) CGFloat backgroundColorAlpha;
@property (nonatomic, assign) BOOL shouldBlend;

@end

@implementation DemoGLFilter

- (instancetype)init {
    self = [super init];
    if (self) {

        runSyncOnVideoProcessingQueue(^{
            [DemoGLContext useImageProcessingContext];
            self.filterProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
            
            [self.filterProgram addAttribute:@"position"];
            [self.filterProgram addAttribute:@"inputTextureCoordinate"];
            
            if (![self.filterProgram link]) {
                NSAssert(NO, @"Filter shader link failed");
            }
            self.filterPositionAttribute = [self.filterProgram attributeIndex:@"position"];
            self.filterTextureCoordinateAttribute = [self.filterProgram attributeIndex:@"inputTextureCoordinate"];
            self.filterInputTextureUniform = [self.filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
            
            glEnableVertexAttribArray(self.filterPositionAttribute);
            glEnableVertexAttribArray(self.filterTextureCoordinateAttribute);
        });
        
    }
    return self;
}

- (void)setupWithBackgroundColor:(UIColor *)color {
    [color getRed:&_backgroundColorRed green:&_backgroundColorGreen blue:&_backgroundColorBlue alpha:&_backgroundColorAlpha];
}

- (void)setupWithShouldBlend:(BOOL)shouldBlend {
    self.shouldBlend = shouldBlend;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [DemoGLContext useImageProcessingContext];
    [self.filterProgram use];
    //这里可能存在self.inputTextureSize会变化的情况，当self.inputTextureSize变化时，产生的输出也会变化
    if (!self.outputTextureFrame ||
        self.outputTextureFrame.width != self.inputTextureSize.width ||
        self.outputTextureFrame.height != self.inputTextureSize.height) {
        self.outputTextureFrame = [[DemoGLTextureFrame alloc] initWithSize:self.inputTextureSize];
    }
    [self.outputTextureFrame activateFramebuffer];
    
    glClearColor(_backgroundColorRed, _backgroundColorGreen, _backgroundColorBlue, _backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (self.shouldBlend) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_inputFramebuffer texture]);
    glUniform1i(self.filterInputTextureUniform, 2);
    
    glVertexAttribPointer(self.filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(self.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    if (self.shouldBlend) {
        glDisable(GL_BLEND);
    }
    
}

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime {
    for (int i = 0; i < self.targets.count; i++) {
        id<DemoGLInputProtocol> target = self.targets[i];
        NSInteger textureIndex = [self.targetTextureIndices[i] integerValue];
        [target setInputTexture:self.outputTextureFrame atIndex:textureIndex];
        [target setInputTextureSize:self.inputTextureSize atIndex:textureIndex];
        [target newFrameReadyAtTime:frameTime timimgInfo:kCMTimingInfoInvalid];
    }
}


#pragma mark - DemoGLInputProtocol

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
    static const GLfloat imageVertices[] = {
        -0.5f, -0.5f,
        0.5f, -0.5f,
        -0.5f,  0.5f,
        0.5f,  0.5f,
    };
    
//    static const GLfloat imageVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:textureCoordinates];

    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)setInputTexture:(DemoGLTextureFrame *)textureFrame atIndex:(NSInteger)index {
    NSAssert(index == 0, @"DemoGLFilter suport one input only");
    _inputFramebuffer = textureFrame;
}

- (void)setInputTextureSize:(CGSize)inputTextureSize atIndex:(NSInteger)index {
    NSAssert(index == 0, @"DemoGLFilter suport one input only");
    _inputTextureSize = inputTextureSize;
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

@end
