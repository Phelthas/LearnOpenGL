//
//  DemoGLStickerFilter.m
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/24.
//

#import "DemoGLStickerFilter.h"
#import "DemoGLShaders.h"
#import "DemoGLContext.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DemoGLGeometry.h"
#import "DemoGLDefines.h"
#import "LXMKit.h"

static GLfloat defaultVertices[] = {
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f,
};

//static GLfloat defaultTextureCoordinates[] = {
//    0.0f, 0.0f,
//    1.0f, 0.0f,
//    0.0f, 1.0f,
//    1.0f, 1.0f,
//};

@interface DemoGLStickerFilter ()

@property (nonatomic, assign) CGSize inputTextureSize;
@property (nonatomic, assign) CGFloat backgroundColorRed;
@property (nonatomic, assign) CGFloat backgroundColorGreen;
@property (nonatomic, assign) CGFloat backgroundColorBlue;
@property (nonatomic, assign) CGFloat backgroundColorAlpha;
@property (nonatomic, assign) BOOL shouldBlend;

@property (nonatomic, strong) DemoGLPicture *glPicture;
@property (nonatomic, assign) CGRect texture2Frame;
@property (nonatomic, assign) GLfloat *vertices2;//secondInputFramebuffer渲染的位置
@property (nonatomic, assign) CGSize superViewSize;//secondInputFramebuffer用来计算顶点的父View大小
@property (nonatomic, assign) BOOL needUpdateVertices2;

@end

@implementation DemoGLStickerFilter

- (instancetype)initWithGLPicture:(DemoGLPicture *)glPicture {
    self = [super init];
    if (self) {
        _glPicture = glPicture;
        _vertices2 = defaultVertices;
        
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


- (void)setupWithTexture2Frame:(CGRect)frame superViewSize:(CGSize)size {
    self.texture2Frame = frame;
    self.superViewSize = size;
    self.needUpdateVertices2 = YES;
}


- (void)updateTexture2VerticesIfNeeded {
    if (!self.needUpdateVertices2) {
        return;
    }
    NSArray<NSNumber *> *array = [self createVerticesForFrame:self.texture2Frame withinSize:self.superViewSize];
    for (int i = 0; i < array.count; i++) {
        // 注意，因为vertices2是指向defaultVertices的，所以这里是把defaultVertices给改了
        self.vertices2[i] = array[i].floatValue;
    }
    self.needUpdateVertices2 = NO;
}

- (NSArray *)createVerticesForFrame:(CGRect)frame withinSize:(CGSize)size {
    NSAssert(size.width > 0 && size.height > 0, @"size should not be zero");
    NSAssert(size.width >= frame.size.width && size.height >= frame.size.height, @"frame should be within size");
    CGRect normalizedRect = CGRectMake(frame.origin.x / size.width,
                                       frame.origin.y / size.height,
                                       frame.size.width / size.width,
                                       frame.size.height / size.height);
    GLfloat vertices[] = {
        CGRectGetBottomLeftPoint(normalizedRect).x, CGRectGetBottomLeftPoint(normalizedRect).y,
        CGRectGetBottomRightPoint(normalizedRect).x, CGRectGetBottomRightPoint(normalizedRect).y,
        CGRectGetTopLeftPoint(normalizedRect).x, CGRectGetTopLeftPoint(normalizedRect).y,
        CGRectGetTopRightPoint(normalizedRect).x, CGRectGetTopRightPoint(normalizedRect).y,
    };
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 8 ; i++) {
        if (i % 2) {
            vertices[i] = coordinateConvertionY(vertices[i]);
        } else {
            vertices[i] = coordinateConvertionX(vertices[i]);
        }
        [array addObject:@(vertices[i])];
    }
    return [array copy];
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
    glClearColor(0, 0, 0, 0);
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
    
    
    
    [self updateTexture2VerticesIfNeeded];
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_glPicture.outputTextureFrame texture]);
    glUniform1i(self.filterInputTextureUniform, 3);
    
    
    glVertexAttribPointer(self.filterPositionAttribute, 2, GL_FLOAT, 0, 0, self.vertices2);
    glVertexAttribPointer(self.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    GetGLErrorOC();
    
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
