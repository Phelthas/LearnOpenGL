//
//  DemoGLTwoInputFilter.m
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/21.
//

#import "DemoGLTwoInputFilter.h"
#import "DemoGLShaders.h"
#import "DemoGLContext.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

NSString *const kGPUImageTwoInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
 }
);


NSString *const kGPUImageTwoInputFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
    
    
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     if (textureColor2.x > 0.0 || textureColor2.y > 0.0 || textureColor2.z > 0.0 || textureColor2.a > 0.0) {
         gl_FragColor = textureColor2;
     } else {
         gl_FragColor = textureColor;
     }
 }
);


@interface DemoGLTwoInputFilter ()

@property (nonatomic, assign) CGSize inputTextureSize;
@property (nonatomic, assign) CGFloat backgroundColorRed;
@property (nonatomic, assign) CGFloat backgroundColorGreen;
@property (nonatomic, assign) CGFloat backgroundColorBlue;
@property (nonatomic, assign) CGFloat backgroundColorAlpha;
@property (nonatomic, assign) BOOL shouldBlend;
@property (nonatomic, assign) BOOL hasSetFirstTexture;
@property (nonatomic, assign) BOOL hasSetSecondTexture;

@end

@implementation DemoGLTwoInputFilter

- (instancetype)init {
    self = [super init];
    if (self) {

        runSyncOnVideoProcessingQueue(^{
            [DemoGLContext useImageProcessingContext];
            self.filterProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:kGPUImageTwoInputFragmentShaderString];
            
            [self.filterProgram addAttribute:@"position"];
            [self.filterProgram addAttribute:@"inputTextureCoordinate"];
            [self.filterProgram addAttribute:@"inputTextureCoordinate2"];
            
            if (![self.filterProgram link]) {
                NSAssert(NO, @"Filter shader link failed");
            }
            self.filterPositionAttribute = [self.filterProgram attributeIndex:@"position"];
            self.filterFisrtTextureCoordinateAttribute = [self.filterProgram attributeIndex:@"inputTextureCoordinate"];
            self.filterSecondTextureCoordinateAttribute = [self.filterProgram attributeIndex:@"inputTextureCoordinate2"];
            self.filterInputTextureUniform = [self.filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
            self.filterInputTextureUniform2 = [self.filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for the fragment shader
            
            glEnableVertexAttribArray(self.filterPositionAttribute);
            glEnableVertexAttribArray(self.filterFisrtTextureCoordinateAttribute);
            glEnableVertexAttribArray(self.filterSecondTextureCoordinateAttribute);
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
    glBindTexture(GL_TEXTURE_2D, [_firstInputFramebuffer texture]);
    glUniform1i(self.filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_secondInputFramebuffer texture]);
    glUniform1i(self.filterInputTextureUniform2, 3);
    
    glVertexAttribPointer(self.filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(self.filterFisrtTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(self.filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
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
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
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
    if (index == 0) {
        _firstInputFramebuffer = textureFrame;
        _hasSetFirstTexture = YES;
    } else if (index == 1) {
        _secondInputFramebuffer = textureFrame;
        _hasSetSecondTexture = YES;
    } else {
        NSAssert(NO, @"DemoGLTwoInputFilter suport two input only");
    }
    
}

- (void)setInputTextureSize:(CGSize)inputTextureSize atIndex:(NSInteger)index {
#warning todo
    /**
     这里还没想好怎么设置inputSize，暂时取较大的
     */
    if (inputTextureSize.width > self.inputTextureSize.width || inputTextureSize.height > self.inputTextureSize.height) {
        _inputTextureSize = inputTextureSize;
    }
    
}

- (NSInteger)nextAvailableTextureIndex {
    if (_hasSetFirstTexture) {
        return 1;
    } else {
        return 0;
    }
}


@end
