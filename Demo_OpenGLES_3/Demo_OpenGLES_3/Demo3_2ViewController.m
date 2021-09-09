//
//  Demo3_2ViewController.m
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import "Demo3_2ViewController.h"
#import "DemoCapturePipline.h"
#import "Demo3GLView.h"
#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>


@interface Demo3_2ViewController ()<DemoCapturePiplineDelegate>

@property (nonatomic, strong) DemoCapturePipline *pipeline;
@property (nonatomic, strong) Demo3_2GLView *glView;


@end

@implementation Demo3_2ViewController

- (void)dealloc {
    [_pipeline stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pipeline = [[DemoCapturePipline alloc] init];
    _pipeline.delegate = self;
    [_pipeline startRunning];
    
    _glView = [[Demo3_2GLView alloc] initWithFrame:self.view.bounds vertexShaderFileName:@"DemoPositionCorodinate.vsh" fragmentShaderFileName:@"DemoTexturePassThrough.fsh"];
    [self.view addSubview:_glView];
   
}

#pragma mark - DemoCapturePiplineDelegate

- (void)capturePipline:(DemoCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.glView displayPixelBuffer:pixelBuffer];
        CFRelease(sampleBuffer);
    });
    
}


@end




#pragma mark ----------------------------------Demo3_2GLView----------------------------------

@interface Demo3_2GLView ()

@property (nonatomic, assign) GLint textureLocation;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, assign) GLuint tempTexture;

@end


@implementation Demo3_2GLView

- (void)bindAttributesIfNeeded {
    [super bindAttributesIfNeeded];
    
    // 绑定的操作必须要在link之前进行，link成功之后生效
    GLint attributeLocation[ShaderAttributeIndexCount] = {ShaderAttributeIndexPosition, ShaderAttributeIndexCoordinate};
    GLchar *attributeName[ShaderAttributeIndexCount] = {"position", "inputCoordinate"};
        
    for (int i = 0; i < ShaderAttributeIndexCount; i++) {
        glBindAttribLocation(_program, attributeLocation[i], attributeName[i]);
    }
}

- (void)setupUniformLocationIfNeeded {
    [super setupUniformLocationIfNeeded];
    _textureLocation = glGetUniformLocation(_program, "texture");

    CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
    if (ret != kCVReturnSuccess) {
        NSLog(@"error %d", ret);
    }
        
//        const VertexAndCoordinate vertices[] = {
//            {GLKVector3Make(-1, -1, 0), GLKVector2Make(0.0, 1.0)},
//            {GLKVector3Make(1, -1, 0), GLKVector2Make(1.0, 1.0)},
//            {GLKVector3Make(-1, 1, 0), GLKVector2Make(0.0, 0.0)},
//            {GLKVector3Make(1, 1, 0), GLKVector2Make(1.0, 0.0)},
//        };
    
    // 设置顶点数组
//    const VertexAndCoordinate vertices[] = {
//        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(0.0, 1.0)},
//        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 1.0)},
//        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 0.0)},
//        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(1.0, 0.0)},
//    };
    
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(0.0, 0.0)},
        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 0.0)},
        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 1.0)},
        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(1.0, 1.0)},
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(ShaderAttributeIndexPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, vertex) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexPosition);
    
    glVertexAttribPointer(ShaderAttributeIndexCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, coordinate) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexCoordinate);
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self displayPixelBuffer1:pixelBuffer];
}

- (void)displayPixelBuffer1:(CVPixelBufferRef)pixelBuffer {

    if (!pixelBuffer) {
        NSLog(@"null pixelBuffer");
        return;
    }
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if (oldContext != _context) {
        if (![EAGLContext setCurrentContext:_context]) {
            NSLog(@"error with context");
            return;
        }
    }
    
    if (!_frameBufferHandler) {
        NSLog(@"error with buffers");
        return;
    }
    
    size_t frameWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    CVOpenGLESTextureRef texture = NULL;
    CVReturn error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _textureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  (GLsizei)frameWidth,
                                                                  (GLsizei)frameHeight,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &texture);
    if (!texture || error) {
        NSLog(@"error with CVOpenGLESTextureCacheCreateTextureFromImage");
        return;
    }
    

    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(_textureLocation, 0);
    
    

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), 0);
    
    CFRelease(texture);
}


@end
