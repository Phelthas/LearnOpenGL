//
//  FiveViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/6/14.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "FiveViewController.h"
#import <GLKit/GLKit.h>
#import "LXMAspectUtil.h"


typedef struct {
    GLKVector3 vertex;
    GLKVector2 coordinate;
} VertexAndCoordinate;

@interface FiveViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation FiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    _glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:_context];
    _glkView.delegate = self;
    [self.view addSubview:_glkView];
    
    // 加载图片纹理
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    GLuint textureID = [self createTextureWithImage:image];
    
    CGSize imageSize = image.size;
    CGSize displaySize = CGSizeMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    CGSize aspectFillSize = [LXMAspectUtil aspectFillSizeForSourceSize:imageSize destinationSize:displaySize];
    //按照aspectFill的方式计算出来的aspectFillSize一定是>=displaySize的
    CGSize samplingSize = CGSizeMake(displaySize.width / aspectFillSize.width, displaySize.height / aspectFillSize.height);
    
    // 注意：AspectFit的方式，不能用这种方式来实现！！！
    
    CGFloat leftX = (1 - samplingSize.width) / 2;
    CGFloat rightX = (1 + samplingSize.width) / 2;
    CGFloat topY = (1 + samplingSize.height) / 2;
    CGFloat bottomY = (1 - samplingSize.height) / 2;
    
    
    const VertexAndCoordinate vertexArray[] = {
        {{0.5, 0.5, 0}, {rightX, topY}},
        {{0.5, -0.5, 0}, {rightX, bottomY}},
        {{-0.5, -0.5, 0}, {leftX, bottomY}},
        {{-0.5, 0.5, 0}, {leftX, topY}},
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), NULL + offsetof(VertexAndCoordinate, vertex));
    
    // 通过 index 的排列组合可以发现：只要这几个点连线画出来是矩形就可以了，跟点的顺序无关
    const GLuint indexArray[] = {
        0, 1, 3,
        1, 2, 3,
    };
    
    GLuint ebo;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexArray), indexArray, GL_STATIC_DRAW);
    
   
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.constantColor = GLKVector4Make(1, 1, 1, 0.5);
    self.baseEffect.texture2d0.name = textureID;
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), NULL + offsetof(VertexAndCoordinate, coordinate));
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
        
    glClearColor(0.5, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

}


#pragma mark - Tool

- (GLuint)createTextureWithImage:(UIImage *)image {
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
