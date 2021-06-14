//
//  ThreeViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/6/2.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "ThreeViewController.h"
#import <GLKit/GLKit.h>



typedef struct {
    GLKVector3 vertex;
    GLKVector2 coordinate;
} VertexAndCoordinate;

@interface ThreeViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    _glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:_context];
    _glkView.delegate = self;
    [self.view addSubview:_glkView];
    
//    const VertexAndCoordinate vertexArray[] = {
//        {{0.5, 0.5, 0}, {1.0, 1.0}},
//        {{0.5, -0.5, 0}, {1.0, 0.0}},
//        {{-0.5, -0.5, 0}, {0.0, 0.0}},
//        {{-0.5, 0.5, 0}, {0.0, 1.0}},
//    };
    
//    const VertexAndCoordinate vertexArray[] = {
//        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 1.0)},
//        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(1.0, 0.0)},
//        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 0.0)},
//        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(0.0, 1.0)},
//    };
    
     ///**
     //使用纹理坐标的旋转实现纹理的旋转
     const VertexAndCoordinate vertexArray[] = {
         {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 0.0)},
         {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(0.0, 0.0)},
         {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 1.0)},
         {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(1.0, 1.0)},
     };
     //*/
    
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
    
    // 加载图片纹理
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
    
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:nil];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.constantColor = GLKVector4Make(1, 1, 1, 0.5);
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), NULL + offsetof(VertexAndCoordinate, coordinate));
    
    // 可以看到图片是被拉伸的，如果要要解决拉伸的问题，一般需要对纹理进行裁剪，对代码来说就是需要按缩放重新计算纹理的坐标
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
        
    glClearColor(0.5, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

}

@end
