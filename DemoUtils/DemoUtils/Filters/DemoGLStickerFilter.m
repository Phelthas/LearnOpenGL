//
//  DemoGLStickerFilter.m
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/24.
//

#import "DemoGLStickerFilter.h"
#import "DemoGLContext.h"
#import "DemoGLGeometry.h"
#import "DemoGLDefines.h"
#import "LXMKit.h"

@interface DemoGLStickerFilter ()

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
        //这里必须用static，否则绘制不出来
        static GLfloat defaultVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        _glPicture = glPicture;
        _vertices2 = defaultVertices;
    }
    return self;
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
    if (!self.outputFramebuffer ||
        self.outputFramebuffer.width != self.inputTextureSize.width ||
        self.outputFramebuffer.height != self.inputTextureSize.height) {
        self.outputFramebuffer = [[DemoGLFramebuffer alloc] initWithSize:self.inputTextureSize];
    }
    [self.outputFramebuffer activateFramebuffer];
    
    glClearColor(self.backgroundColorRed, self.backgroundColorGreen, self.backgroundColorBlue, self.backgroundColorAlpha);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (self.shouldBlend) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [self.inputFramebuffer texture]);
    glUniform1i(self.filterInputTextureUniform, 2);
    
    glVertexAttribPointer(self.filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(self.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    
    [self updateTexture2VerticesIfNeeded];
    
    if ([self.glPicture isUsingImageArray]) {
        [self.glPicture setupWithNextImage];
    }
    
    
    static const GLfloat textureCoordinates2[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_glPicture.outputFramebuffer texture]);
    glUniform1i(self.filterInputTextureUniform, 3);
    
    
    glVertexAttribPointer(self.filterPositionAttribute, 2, GL_FLOAT, 0, 0, self.vertices2);
    glVertexAttribPointer(self.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates2);
    GetGLErrorOC();
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    if (self.shouldBlend) {
        glDisable(GL_BLEND);
    }
    
}

@end
